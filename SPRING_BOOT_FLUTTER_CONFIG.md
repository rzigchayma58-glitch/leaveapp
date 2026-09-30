# 🔧 CONFIGURATION SPRING BOOT POUR TABLES FLUTTER

## 📋 MODIFICATIONS À FAIRE DANS VOTRE BACKEND

### 1. Mise à jour des Entity classes

```java
// FlutterLeaveType.java
@Entity
@Table(name = "flutter_leave_types")
public class FlutterLeaveType {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    private String description;
    private Integer maxDays;
    private Boolean isActive;
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    // getters et setters...
}

// FlutterLeaveRequest.java
@Entity
@Table(name = "flutter_leave_requests")
public class FlutterLeaveRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private Long requesterId;
    private Long approverId;
    private Long leaveTypeId;
    
    private LocalDate startDate;
    private LocalDate endDate;
    private BigDecimal requestedDays;
    
    private String reason;
    
    @Enumerated(EnumType.STRING)
    private LeaveStatus status;
    
    @CreationTimestamp
    private LocalDateTime submittedAt;
    
    private LocalDateTime decisionAt;
    private String decisionComment;
    
    private String createdFrom = "FLUTTER_APP";
    private String deviceInfo;
    private String appVersion;
    
    // getters et setters...
}

// FlutterLeaveBalance.java
@Entity
@Table(name = "flutter_leave_balances")
public class FlutterLeaveBalance {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private Long userId;
    private Long leaveTypeId;
    private Integer year;
    
    private BigDecimal totalDays;
    private BigDecimal usedDays;
    // remainingDays est calculé automatiquement par MySQL
    
    @CreationTimestamp
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    private LocalDateTime updatedAt;
    
    // getters et setters...
}
```

### 2. Repository interfaces

```java
// FlutterLeaveTypeRepository.java
@Repository
public interface FlutterLeaveTypeRepository extends JpaRepository<FlutterLeaveType, Long> {
    List<FlutterLeaveType> findByIsActiveTrue();
}

// FlutterLeaveRequestRepository.java
@Repository
public interface FlutterLeaveRequestRepository extends JpaRepository<FlutterLeaveRequest, Long> {
    List<FlutterLeaveRequest> findByRequesterId(Long requesterId);
    List<FlutterLeaveRequest> findByApproverId(Long approverId);
    List<FlutterLeaveRequest> findByStatus(LeaveStatus status);
}

// FlutterLeaveBalanceRepository.java
@Repository
public interface FlutterLeaveBalanceRepository extends JpaRepository<FlutterLeaveBalance, Long> {
    List<FlutterLeaveBalance> findByUserId(Long userId);
    List<FlutterLeaveBalance> findByUserIdAndYear(Long userId, Integer year);
}
```

### 3. Controller endpoints Flutter

```java
@RestController
@RequestMapping("/api/flutter")
public class FlutterLeaveController {

    @Autowired
    private FlutterLeaveTypeRepository leaveTypeRepo;
    
    @Autowired
    private FlutterLeaveRequestRepository leaveRequestRepo;
    
    @Autowired
    private FlutterLeaveBalanceRepository leaveBalanceRepo;

    // GET /api/flutter/leave-types
    @GetMapping("/leave-types")
    public List<FlutterLeaveType> getLeaveTypes() {
        return leaveTypeRepo.findByIsActiveTrue();
    }
    
    // POST /api/flutter/leave-requests
    @PostMapping("/leave-requests")
    public ResponseEntity<?> createLeaveRequest(@RequestBody FlutterLeaveRequestDTO request) {
        try {
            FlutterLeaveRequest leaveRequest = new FlutterLeaveRequest();
            leaveRequest.setRequesterId(request.getRequesterId());
            leaveRequest.setLeaveTypeId(request.getLeaveTypeId());
            leaveRequest.setStartDate(request.getStartDate());
            leaveRequest.setEndDate(request.getEndDate());
            leaveRequest.setReason(request.getReason());
            leaveRequest.setStatus(LeaveStatus.PENDING);
            leaveRequest.setCreatedFrom("FLUTTER_APP");
            
            FlutterLeaveRequest saved = leaveRequestRepo.save(leaveRequest);
            
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Demande créée avec succès",
                "requestId", saved.getId()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", e.getMessage()
            ));
        }
    }
    
    // GET /api/flutter/leave-requests/user/{userId}
    @GetMapping("/leave-requests/user/{userId}")
    public List<FlutterLeaveRequest> getUserRequests(@PathVariable Long userId) {
        return leaveRequestRepo.findByRequesterId(userId);
    }
    
    // GET /api/flutter/leave-balances/user/{userId}
    @GetMapping("/leave-balances/user/{userId}")
    public List<FlutterLeaveBalance> getUserBalances(@PathVariable Long userId) {
        return leaveBalanceRepo.findByUserId(userId);
    }
}
```

## 🎯 ÉTAPES D'IMPLÉMENTATION

### Option A: Modification minimale du backend

Si vous ne voulez pas modifier le backend Spring Boot, nous pouvons configurer Flutter pour utiliser directement les nouvelles tables via des requêtes SQL personnalisées.

### Option B: Backend complet (recommandé)

1. Ajoutez les classes Entity ci-dessus
2. Créez les Repository interfaces
3. Ajoutez le FlutterLeaveController
4. Redémarrez votre backend

## 🚀 AVANTAGES DE CETTE APPROCHE

✅ **Pas de modification des données existantes**
✅ **Tables dédiées Flutter avec métadonnées**
✅ **Vues SQL pour requêtes simplifiées**
✅ **Possibilité de rollback sans impact**
✅ **Tests isolés**

## 📱 CONFIGURATION FLUTTER

Une fois les tables créées, nous mettrons à jour votre Flutter pour utiliser les nouveaux endpoints :

```dart
// Dans ApiConfig.dart
static String get flutterLeaveTypes => '$baseUrl/flutter/leave-types';
static String get flutterLeaveRequests => '$baseUrl/flutter/leave-requests';
static String get flutterLeaveBalances => '$baseUrl/flutter/leave-balances';
```

Voulez-vous que je prépare aussi la version Flutter qui utilise ces nouvelles tables ?