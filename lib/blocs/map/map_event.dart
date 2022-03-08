part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class OnMapInitializedEvent extends MapEvent {
  final GoogleMapController controller;
  const OnMapInitializedEvent(this.controller);
}

class OnStartFollowingUserEvent extends MapEvent {}

class OnStopFollowingUserEvent extends MapEvent {}

class UpdateNotificationMarkerEvent extends MapEvent {
  final QuerySnapshot<Map<String, dynamic>> notifications;
  const UpdateNotificationMarkerEvent(this.notifications);
}

class OnToggleUserRoute extends MapEvent {}
