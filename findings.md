# Script Analysis & Findings

## 1. Project Structure & Organization

### 1.1 "God Object" Dependency Injection
**Observation:** `combat_scene.gd` is acting as a massive manual dependency injection container. It explicitly injects every service into every other service/manager.
**Issue:** This makes `combat_scene.gd` brittle and hard to maintain. Adding a new service requires updating multiple lines in `combat_scene.gd`.
**Suggestion:**
- Use a dedicated `GameContext` or `ServiceLocator` autoload (singleton) to manage global services.
- Alternatively, use a proper dependency injection framework or pattern where services register themselves.

### 1.2 Deprecated & Test Files
**Observation:**
- `OLDcombat_state_machine.gd` exists.
- `unit_xcom.gd` and `unit_xcom_2.gd` seem to be abandoned prototypes or duplicate attempts.
**Issue:** Clutters the codebase and confuses future developers (including AI).
**Suggestion:** Delete these files if they are not in use.

### 1.3 State Machine Confusion
**Observation:** There are multiple state machine folders (`combat_state_machine`, `turn_state_machine`, `unit_state_machine`). `unit_action_move.gd` (generic state) vs `generic_state.gd`.
**Issue:** It's unclear if these share a common base or pattern. The presence of `OLD` files suggests a refactor half-done.
**Suggestion:** Standardize on one State Machine implementation (likely `state_machine.gd`) and ensure all specific state machines inherit from it correctly.

## 2. Code Quality & Performance

### 2.1 Pathfinding Performance
**Observation:** `PathfindingService.gd` uses `open_set.sort_custom(...)` inside the A* loop.
**Issue:** This is extremely inefficient (O(N^2 log N) or worse). For short paths, it's fine, but it will cause frame drops on longer paths.
**Suggestion:**
- Use a Binary Heap implementation for the priority queue.
- Remove debug `print` statements inside the tight loops!

### 2.2 Duplicate Logic
**Observation:** `pathfinding_service.gd` has `find_path` and `find_path2`.
**Issue:** Duplicate code leads to bugs when one is updated and the other isn't.
**Suggestion:** Remove the unused one (likely `find_path2` or merge them).

### 2.3 Hardcoded Values
**Observation:** `unit_manager.gd` uses hardcoded strings like `"u" + str(next_unit_id)` and accesses `UnitTypes` via string keys.
**Issue:** Prone to typos and runtime errors.
**Suggestion:** Use constants or Enums for IDs and Types.

### 2.4 Debug Prints
**Observation:** Many files (`pathfinding_service.gd`, `unit_manager.gd`, etc.) have `#print()` calls that seem to be for ephemeral debugging.
**Issue:** Pollutes the output log and impacts performance (especially in loops).
**Suggestion:** Remove them or use a dedicated logger with log levels.

## 3. Specific Improvements

| File | Issue | Proposed Fix |
|------|-------|--------------|
| `scripts/OLDcombat_state_machine.gd` | Deprecated file | **DELETE** |
| `scripts/entities/unit_xcom*.gd` | Abandoned files | **DELETE** (if confirmed unused) |
| `scripts/services/pathfinding_service.gd` | Perf & Duplication | Remove `find_path2`, implement Heap, remove prints |
| `scripts/combat_scene.gd` | Initialization Bloat | Extract `ServiceContainer` logic or use Autoloads for core services |
| `scripts/components/weapon_component.gd` | Commented code | Remove or uncomment `los_service` check |

## Recommended Action Plan

1.  **Cleanup:** Delete `OLD` files and clearly unused prototypes.
2.  **Fix High Priority Issues:** Fix Pathfinding performance and duplication.
3.  **Refactor:** Standardize State Machines.
4.  **Architectural Shift:** Move away from `combat_scene.gd` manual injection (Long term).
