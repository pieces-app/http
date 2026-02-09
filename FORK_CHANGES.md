# Fork Changes Documentation

This document tracks all custom modifications, patches, and deviations from the upstream `dart-lang/http` repository.

## Fork Information

- **Fork Repository**: `https://github.com/pieces-app/http`
- **Upstream Repository**: `https://github.com/dart-lang/http`
- **Current Branch**: `master`
- **Fork Version**: `1.2.3-wip` (note the `-wip` suffix)
- **Commits Ahead**: 5
- **Commits Behind**: 386
- **Last Upstream Merge**: Fork created from upstream circa 2023

## Custom Modifications

### 1. Custom HTTP Client Support
- **Commits**: `637ad9e`, `66e75fb`
- **Changes**:
  - Added support for providing a custom HTTP client to the web_socket implementation
  - Renamed custom client parameter for clarity
- **Reason**: Required for Pieces to inject custom HTTP client configurations (e.g., for proxy support, custom certificates)

### 2. Dynamic WebSocket and Stub Connect Client
- **Commit**: `51b0dbb`
- **Changes**:
  - Updated WebSocket and stub connect client to be dynamic
- **Reason**: Flexibility in WebSocket connection handling

### 3. Documentation Updates
- **Commit**: `c617735`
- **Changes**: Updated docs for the custom client feature

### 4. Pubspec Update
- **Commit**: `0020d50`
- **Changes**: Updated pubspec.yaml

## Workspace Integration

The `web_socket` sub-package from this fork is overridden at the workspace root:

```yaml
# In root pubspec.yaml
dependency_overrides:
  web_socket:
    git:
      url: git@github.com:pieces-app/http.git
      path: pkgs/web_socket
```

## Upstream Sync Status

- **Current Gap**: 386 commits behind upstream/master
- **Complexity**: MEDIUM -- our changes are isolated to web_socket sub-package
- **Priority**: MEDIUM -- upstream has significant improvements but our changes are small

### Recommended Sync Approach
1. Fetch upstream master
2. Attempt merge -- our 5 commits are focused on `pkgs/web_socket/`
3. Resolve any conflicts in the web_socket package
4. Test WebSocket functionality after merge
5. Verify custom HTTP client injection still works

## Why This Fork Exists

1. **Custom HTTP Client Injection**: Upstream does not support providing a custom HTTP client to the web_socket implementation
2. **Dynamic WebSocket Handling**: Required for Pieces' WebSocket connection management

## Future Considerations

1. **Upstream Contribution**: The custom HTTP client support could be valuable upstream -- consider contributing it
2. **Check Upstream API**: Newer upstream versions may have added similar functionality
3. **Minimize Fork Surface**: Only the `pkgs/web_socket/` sub-package is modified; consider if there's a way to use upstream for everything else

## Contact

For questions about this fork or to request changes, contact the Pieces development team.
