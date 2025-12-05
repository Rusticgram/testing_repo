part of 'account_cubit.dart';

class AccountState {
  final DataState dataState;
  final OrderState orderState;
  final Uint8List profilePic;
  final String name;
  final String email;
  final String mobile;
  final UserAddress address;
  final String errorMessage;

  const AccountState({
    required this.dataState,
    required this.orderState,
    required this.profilePic,
    required this.name,
    required this.email,
    required this.mobile,
    required this.address,
    required this.errorMessage,
  });

  factory AccountState.initial() => AccountState(
    dataState: DataState.initial,
    orderState: OrderState.initial,
    profilePic: Uint8List.fromList([]),
    name: "",
    email: "",
    mobile: "",
    address: UserAddress.fromJson({}),
    errorMessage: "",
  );

  AccountState copyWith({DataState? dataState, OrderState? orderState, Uint8List? profilePic, String? name, String? email, String? mobile, UserAddress? address, String? errorMessage}) {
    return AccountState(
      dataState: dataState ?? this.dataState,
      orderState: orderState ?? this.orderState,
      profilePic: profilePic ?? this.profilePic,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
