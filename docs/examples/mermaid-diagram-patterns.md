---
title: "Mermaid Diagram Patterns for Planning"
version: "1.0.0"
date: "2025-11-17"
status: "final"
---

# Mermaid Diagram Patterns

This guide provides reusable Mermaid diagram patterns for use in planning documents. Include diagrams when they clarify architecture, workflows, state transitions, or data flows beyond what prose can convey.

## When to Include Diagrams

**Required for:**
- Architecture changes affecting multiple components
- Multi-phase workflows with parallel or conditional paths
- State machines with complex transitions
- Data pipelines with transformations

**Optional for:**
- Simple linear workflows
- Single-component changes
- Minor refactorings

**Never for:**
- Trivial bug fixes
- Documentation-only updates

---

## Architecture Diagrams

### Component Architecture

Use flowcharts to show system components and their relationships:

```mermaid
flowchart TD
    UI[User Interface]
    API[API Layer]
    BL[Business Logic]
    DAL[Data Access Layer]
    DB[(Database)]
    Cache[(Redis Cache)]
    
    UI --> API
    API --> BL
    BL --> DAL
    DAL --> DB
    BL --> Cache
    
    style UI fill:#e1f5ff
    style API fill:#fff4e1
    style BL fill:#ffe1f5
    style DAL fill:#e1ffe1
    style DB fill:#f5e1e1
    style Cache fill:#f5e1e1
```

### Layered Architecture

Show architectural layers and cross-cutting concerns:

```mermaid
flowchart TB
    subgraph Presentation
        UI[Web UI]
        API[REST API]
    end
    
    subgraph Application
        Auth[Authentication]
        BL[Business Logic]
        Valid[Validation]
    end
    
    subgraph Infrastructure
        Repo[Repositories]
        Cache[Caching]
        Log[Logging]
    end
    
    subgraph Data
        DB[(Database)]
        Queue[Message Queue]
    end
    
    UI --> Auth
    API --> Auth
    Auth --> BL
    BL --> Valid
    Valid --> Repo
    Repo --> DB
    BL --> Cache
    Application -.-> Log
    
    style Presentation fill:#e1f5ff
    style Application fill:#fff4e1
    style Infrastructure fill:#ffe1f5
    style Data fill:#e1ffe1
```

### Microservices Architecture

Show service boundaries and communication patterns:

```mermaid
flowchart LR
    Client[Client Application]
    Gateway[API Gateway]
    
    subgraph Services
        UserSvc[User Service]
        OrderSvc[Order Service]
        PaymentSvc[Payment Service]
        NotifySvc[Notification Service]
    end
    
    subgraph Data
        UserDB[(User DB)]
        OrderDB[(Order DB)]
        PaymentDB[(Payment DB)]
    end
    
    Queue[Message Queue]
    
    Client --> Gateway
    Gateway --> UserSvc
    Gateway --> OrderSvc
    Gateway --> PaymentSvc
    
    UserSvc --> UserDB
    OrderSvc --> OrderDB
    PaymentSvc --> PaymentDB
    
    OrderSvc --> Queue
    PaymentSvc --> Queue
    Queue --> NotifySvc
    
    style Gateway fill:#e1f5ff
    style Services fill:#fff4e1
    style Data fill:#ffe1f5
```

---

## Workflow Diagrams

### Sequence Diagrams

Show interactions between components over time:

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant Auth
    participant API
    participant Database
    
    User->>Frontend: Login Request
    Frontend->>Auth: Authenticate
    Auth->>Database: Validate Credentials
    Database-->>Auth: User Record
    Auth-->>Frontend: JWT Token
    Frontend-->>User: Login Success
    
    User->>Frontend: Data Request
    Frontend->>API: API Call + Token
    API->>Auth: Validate Token
    Auth-->>API: Token Valid
    API->>Database: Query Data
    Database-->>API: Results
    API-->>Frontend: JSON Response
    Frontend-->>User: Display Data
```

### Process Flow with Decision Points

Show conditional logic and branching:

```mermaid
flowchart TD
    Start([Start Request]) --> Validate{Valid Input?}
    Validate -->|No| Error[Return Error]
    Validate -->|Yes| Auth{Authenticated?}
    Auth -->|No| Error
    Auth -->|Yes| Authorized{Authorized?}
    Authorized -->|No| Error
    Authorized -->|Yes| Process[Process Request]
    Process --> Cache{In Cache?}
    Cache -->|Yes| Return[Return Cached]
    Cache -->|No| Query[Query Database]
    Query --> Store[Store in Cache]
    Store --> Return
    Return --> End([Return Response])
    Error --> End
    
    style Start fill:#e1f5ff
    style End fill:#e1ffe1
    style Error fill:#ffe1e1
    style Process fill:#fff4e1
```

### Parallel Workflows

Show concurrent operations:

```mermaid
flowchart TD
    Start([Receive Order]) --> Split[Process Order]
    Split --> Inventory[Check Inventory]
    Split --> Payment[Process Payment]
    Split --> Shipping[Calculate Shipping]
    
    Inventory --> Sync{All Complete?}
    Payment --> Sync
    Shipping --> Sync
    
    Sync --> Confirm[Confirm Order]
    Confirm --> Notify[Send Notification]
    Notify --> End([Complete])
    
    style Start fill:#e1f5ff
    style End fill:#e1ffe1
    style Sync fill:#fff4e1
```

---

## State Diagrams

### Lifecycle State Machine

Show state transitions and triggers:

```mermaid
stateDiagram-v2
    [*] --> Draft: Create
    Draft --> InReview: Submit
    InReview --> Draft: Request Changes
    InReview --> Approved: Approve
    Approved --> Published: Publish
    Published --> Archived: Archive
    Draft --> Cancelled: Cancel
    InReview --> Cancelled: Reject
    Cancelled --> [*]
    Archived --> [*]
    
    note right of Draft
        Editable state
        Can be saved
    end note
    
    note right of Published
        Read-only
        Publicly visible
    end note
```

### Order Processing States

Business process with error states:

```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Processing: Start
    Processing --> PaymentPending: Validate
    PaymentPending --> PaymentComplete: Pay
    PaymentPending --> PaymentFailed: Error
    PaymentFailed --> Cancelled
    PaymentComplete --> Fulfillment
    Fulfillment --> Shipped: Ship
    Shipped --> Delivered: Confirm
    Delivered --> [*]
    
    Processing --> Cancelled: Timeout
    Cancelled --> [*]
```

---

## Data Flow Diagrams

### ETL Pipeline

Show data transformation stages:

```mermaid
flowchart LR
    Source1[(Source DB 1)]
    Source2[(Source DB 2)]
    API[External API]
    
    Extract[Extract]
    Validate[Validate]
    Transform[Transform]
    Enrich[Enrich]
    Load[Load]
    
    Target[(Data Warehouse)]
    Monitor[Monitoring]
    ErrorLog[(Error Log)]
    
    Source1 --> Extract
    Source2 --> Extract
    API --> Extract
    
    Extract --> Validate
    Validate --> Transform
    Transform --> Enrich
    Enrich --> Load
    Load --> Target
    
    Validate -.->|Errors| ErrorLog
    Transform -.->|Metrics| Monitor
    Load -.->|Metrics| Monitor
    
    style Extract fill:#e1f5ff
    style Transform fill:#fff4e1
    style Load fill:#e1ffe1
    style ErrorLog fill:#ffe1e1
```

### Event-Driven Architecture

Show event flows and subscribers:

```mermaid
flowchart TD
    Producer1[Order Service]
    Producer2[Payment Service]
    Producer3[User Service]
    
    EventBus[Event Bus]
    
    Consumer1[Email Service]
    Consumer2[Analytics Service]
    Consumer3[Audit Service]
    Consumer4[Notification Service]
    
    Producer1 -->|OrderCreated| EventBus
    Producer1 -->|OrderCancelled| EventBus
    Producer2 -->|PaymentProcessed| EventBus
    Producer3 -->|UserRegistered| EventBus
    
    EventBus -->|Subscribe| Consumer1
    EventBus -->|Subscribe| Consumer2
    EventBus -->|Subscribe| Consumer3
    EventBus -->|Subscribe| Consumer4
    
    style EventBus fill:#fff4e1
    style Producer1 fill:#e1f5ff
    style Producer2 fill:#e1f5ff
    style Producer3 fill:#e1f5ff
```

---

## Implementation Phase Diagrams

### TDD Workflow

Show test-first development cycle:

```mermaid
flowchart TD
    Start([Start Phase]) --> Write[Write Failing Test]
    Write --> Run1[Run Tests]
    Run1 --> Fail{Tests Fail?}
    Fail -->|No| Error[Error: Test should fail]
    Fail -->|Yes| Implement[Write Minimal Code]
    Implement --> Run2[Run Tests]
    Run2 --> Pass{Tests Pass?}
    Pass -->|No| Debug[Debug & Fix]
    Debug --> Run2
    Pass -->|Yes| Refactor{Refactor Needed?}
    Refactor -->|Yes| Clean[Refactor Code]
    Clean --> Run3[Run Tests]
    Run3 --> Verify{Still Pass?}
    Verify -->|No| Rollback[Rollback Changes]
    Rollback --> Refactor
    Verify -->|Yes| More{More Tests?}
    Refactor -->|No| More
    More -->|Yes| Write
    More -->|No| End([Phase Complete])
    
    style Start fill:#e1f5ff
    style End fill:#e1ffe1
    style Error fill:#ffe1e1
```

### Code Review Process

Show review workflow with multiple reviewers:

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant CI as CI/CD
    participant Rev1 as Reviewer 1
    participant Rev2 as Reviewer 2
    participant Sec as Security Agent
    participant Perf as Performance Agent
    
    Dev->>CI: Push Changes
    CI->>CI: Run Tests
    CI->>CI: Run Linters
    CI->>CI: Security Scan
    CI-->>Dev: Build Results
    
    Dev->>Rev1: Request Review
    Dev->>Rev2: Request Review
    
    Rev1->>Sec: Security Check
    Sec-->>Rev1: APPROVED
    
    Rev2->>Perf: Performance Check
    Perf-->>Rev2: MINOR Issues
    
    Rev1-->>Dev: APPROVED
    Rev2-->>Dev: NEEDS_REVISION
    
    Dev->>Dev: Address Feedback
    Dev->>Rev2: Re-request Review
    Rev2-->>Dev: APPROVED
    
    Dev->>CI: Merge
```

---

## Styling Guidelines

### Color Scheme

Use consistent colors to represent different layers or states:

- **Input/Start**: Light Blue (`#e1f5ff`)
- **Processing**: Light Yellow (`#fff4e1`)
- **Data Storage**: Light Pink (`#ffe1f5`)
- **Output/Success**: Light Green (`#e1ffe1`)
- **Error/Warning**: Light Red (`#ffe1e1`)

### Example with Styling

```mermaid
flowchart TD
    Input[User Input] --> Validate[Validation]
    Validate -->|Valid| Process[Processing]
    Validate -->|Invalid| Error[Error Handler]
    Process --> Store[(Database)]
    Store --> Output[Success Response]
    Error --> Output
    
    style Input fill:#e1f5ff
    style Process fill:#fff4e1
    style Store fill:#ffe1f5
    style Output fill:#e1ffe1
    style Error fill:#ffe1e1
```

---

## Best Practices

1. **Keep diagrams focused**: One diagram per concern (architecture, workflow, data flow)
2. **Use meaningful labels**: Component names should match actual code/system names
3. **Show key paths only**: Omit implementation details that don't affect the plan
4. **Include legends when needed**: Explain non-obvious notation or color coding
5. **Validate diagram syntax**: Test in Mermaid Live Editor before committing
6. **Update diagrams with code**: Keep visual documentation in sync with implementation

---

## Tools & Resources

- **Mermaid Live Editor**: https://mermaid.live/
- **VS Code Mermaid Extension**: Install "Markdown Preview Mermaid Support"
- **Mermaid Documentation**: https://mermaid.js.org/
- **GitHub Mermaid Support**: Renders automatically in Markdown files

---

## Validation

Before finalizing a plan with diagrams:

- [ ] Diagram syntax is valid (test in Mermaid Live Editor)
- [ ] Labels match actual component/function names
- [ ] Color coding follows the established scheme
- [ ] Diagram adds clarity beyond prose description
- [ ] Related diagrams are consistent in notation
- [ ] Complex diagrams include notes or legends

---

**See Also:**
- `docs/templates/plan.md` - Plan template with diagram sections
- `instructions/workflows/planner.instructions.md` - Planner agent requirements
