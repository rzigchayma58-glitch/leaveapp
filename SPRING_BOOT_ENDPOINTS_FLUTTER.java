// 🚀 ENDPOINTS SPRING BOOT POUR FLUTTER
// Ajouter ces méthodes dans ton controller Spring Boot

@RestController
@RequestMapping("/api")
public class FlutterLeaveController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // ========================================
    // 1. ENDPOINT TYPES DE CONGÉ
    // ========================================
    
    @GetMapping("/leave-types")
    public ResponseEntity<List<Map<String, Object>>> getLeaveTypes() {
        try {
            String sql = "SELECT id, name, description, is_active FROM flutter_leave_types WHERE is_active = TRUE ORDER BY id";
            List<Map<String, Object>> types = jdbcTemplate.queryForList(sql);
            return ResponseEntity.ok(types);
        } catch (Exception e) {
            // Fallback avec types hardcodés si table pas encore créée
            List<Map<String, Object>> fallbackTypes = Arrays.asList(
                Map.of("id", 1, "name", "CONGÉ", "description", "Congé annuel", "is_active", true),
                Map.of("id", 2, "name", "AUTORISATION_ABSENCE", "description", "Autorisation d'absence", "is_active", true)
            );
            return ResponseEntity.ok(fallbackTypes);
        }
    }

    // ========================================
    // 2. ENDPOINT CRÉATION DEMANDE
    // ========================================
    
    @PostMapping("/leave-requests")
    public ResponseEntity<?> createLeaveRequest(@RequestBody Map<String, Object> request) {
        try {
            // Récupérer les données
            Long requesterId = Long.valueOf(request.get("requesterId").toString());
            Integer leaveTypeId = Integer.valueOf(request.get("leaveTypeId").toString());
            String startDate = request.get("startDate").toString();
            String endDate = request.get("endDate").toString();
            Double requestedDays = Double.valueOf(request.get("requestedDays").toString());
            String reason = request.get("reason") != null ? request.get("reason").toString() : "";

            // Vérifier que le type existe
            String checkTypeSql = "SELECT COUNT(*) FROM flutter_leave_types WHERE id = ? AND is_active = TRUE";
            Integer typeExists = jdbcTemplate.queryForObject(checkTypeSql, Integer.class, leaveTypeId);
            
            if (typeExists == 0) {
                return ResponseEntity.status(404).body(Map.of(
                    "error", "Not Found",
                    "message", "Leave type not found with id: " + leaveTypeId,
                    "path", "/api/leave-requests",
                    "status", 404,
                    "timestamp", new Date()
                ));
            }

            // Insérer la demande
            String insertSql = """
                INSERT INTO flutter_leave_requests 
                (requester_id, leave_type_id, start_date, end_date, requested_days, reason, status, submitted_at) 
                VALUES (?, ?, ?, ?, ?, ?, 'PENDING', NOW())
                """;
            
            KeyHolder keyHolder = new GeneratedKeyHolder();
            jdbcTemplate.update(connection -> {
                PreparedStatement ps = connection.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
                ps.setLong(1, requesterId);
                ps.setInt(2, leaveTypeId);
                ps.setString(3, startDate);
                ps.setString(4, endDate);
                ps.setDouble(5, requestedDays);
                ps.setString(6, reason);
                return ps;
            }, keyHolder);

            Long generatedId = keyHolder.getKey().longValue();

            return ResponseEntity.status(201).body(Map.of(
                "id", generatedId,
                "message", "Leave request created successfully",
                "status", "PENDING"
            ));

        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of(
                "error", "Internal Server Error",
                "message", "Failed to create leave request: " + e.getMessage()
            ));
        }
    }

    // ========================================
    // 3. ENDPOINT HISTORIQUE UTILISATEUR
    // ========================================
    
    @GetMapping("/leave-requests/requester/{userId}")
    public ResponseEntity<List<Map<String, Object>>> getUserRequests(@PathVariable Long userId) {
        try {
            String sql = """
                SELECT 
                    flr.id,
                    flr.requester_id,
                    flr.leave_type_id,
                    flt.name as leave_type_name,
                    flr.start_date,
                    flr.end_date,
                    flr.requested_days,
                    flr.reason,
                    flr.status,
                    flr.submitted_at,
                    flr.reviewed_at,
                    flr.decision_comment
                FROM flutter_leave_requests flr
                JOIN flutter_leave_types flt ON flr.leave_type_id = flt.id
                WHERE flr.requester_id = ?
                ORDER BY flr.submitted_at DESC
                """;
            
            List<Map<String, Object>> requests = jdbcTemplate.queryForList(sql, userId);
            return ResponseEntity.ok(requests);
            
        } catch (Exception e) {
            // Retourner liste vide si erreur
            return ResponseEntity.ok(Arrays.asList());
        }
    }

    // ========================================
    // 4. ENDPOINT DEMANDES MANAGER
    // ========================================
    
    @GetMapping("/leave-requests/team/{managerId}")
    public ResponseEntity<List<Map<String, Object>>> getTeamRequests(@PathVariable Long managerId) {
        try {
            // Récupérer les demandes des employés sous ce manager
            String sql = """
                SELECT 
                    flr.id,
                    flr.requester_id,
                    CONCAT(req.firstName, ' ', req.lastName) as requester_name,
                    flr.leave_type_id,
                    flt.name as leave_type_name,
                    flr.start_date,
                    flr.end_date,
                    flr.requested_days,
                    flr.reason,
                    flr.status,
                    flr.submitted_at
                FROM flutter_leave_requests flr
                JOIN users req ON flr.requester_id = req.id
                JOIN flutter_leave_types flt ON flr.leave_type_id = flt.id
                WHERE req.managerId = ? OR flr.approver_id IS NULL
                ORDER BY flr.submitted_at DESC
                """;
            
            List<Map<String, Object>> requests = jdbcTemplate.queryForList(sql, managerId);
            return ResponseEntity.ok(requests);
            
        } catch (Exception e) {
            return ResponseEntity.ok(Arrays.asList());
        }
    }

    // ========================================
    // 5. ENDPOINT APPROBATION/REJET
    // ========================================
    
    @PatchMapping("/leave-requests/{requestId}/approve")
    public ResponseEntity<?> approveRequest(@PathVariable Long requestId, @RequestBody Map<String, String> body) {
        try {
            String comment = body.get("comments");
            
            String sql = """
                UPDATE flutter_leave_requests 
                SET status = 'APPROVED', reviewed_at = NOW(), decision_comment = ?
                WHERE id = ?
                """;
            
            int updated = jdbcTemplate.update(sql, comment, requestId);
            
            if (updated > 0) {
                return ResponseEntity.ok(Map.of("message", "Request approved successfully"));
            } else {
                return ResponseEntity.status(404).body(Map.of("error", "Request not found"));
            }
            
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    @PatchMapping("/leave-requests/{requestId}/reject")
    public ResponseEntity<?> rejectRequest(@PathVariable Long requestId, @RequestBody Map<String, String> body) {
        try {
            String comment = body.get("comments");
            String reason = body.get("reason");
            
            String sql = """
                UPDATE flutter_leave_requests 
                SET status = 'REJECTED', reviewed_at = NOW(), decision_comment = ?, rejection_reason = ?
                WHERE id = ?
                """;
            
            int updated = jdbcTemplate.update(sql, comment, reason, requestId);
            
            if (updated > 0) {
                return ResponseEntity.ok(Map.of("message", "Request rejected successfully"));
            } else {
                return ResponseEntity.status(404).body(Map.of("error", "Request not found"));
            }
            
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }
}