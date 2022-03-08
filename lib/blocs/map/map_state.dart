part of 'map_bloc.dart';

class MapState extends Equatable {
  final bool isMapInitialized;
  final bool isFollowingUser;

  final Set<Marker> markers;

  const MapState(
      {this.isMapInitialized = false,
      this.isFollowingUser = false,
      Set<Marker>? markers})
      : markers = markers ?? const {};

  MapState copyWith({
    bool? isMapInitialized,
    bool? isFollowingUser,
    Set<Marker>? markers,
  }) =>
      MapState(
        isMapInitialized: isMapInitialized ?? this.isMapInitialized,
        isFollowingUser: isFollowingUser ?? this.isFollowingUser,
        markers: markers ?? this.markers,
      );

  @override
  List<Object> get props => [isMapInitialized, isFollowingUser, markers];
}
