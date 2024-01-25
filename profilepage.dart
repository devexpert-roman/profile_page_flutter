class SignedInPage extends StatefulWidget {
  final ProfileModel profile;
  const SignedInPage({Key? key, required this.profile}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignedInPageState();
}

class _SignedInPageState extends State<SignedInPage> {
  // @override
  // void initState() {}

  late AppProvider provider;
  LocationProvider? locProvider;
  OrdersHistoryProvider? _ordersHistoryProvider;
  PackageInfo? packageInfo;
  DeviceInfoPlugin? deviceInfo;
  bool _isInit = false;
  Completer? _completer;
  final MaskedTextController phoneController =
      MaskedTextController(mask: '+7 000 000 00 00');

  bool isOpening = false;
  String _sistemVersion = '';
  String _device = '';
  String singleDeviceNameFromModel = "Unknown";

  @override
  void initState() {
    eventBus.on<UpdateActiveOrdersEvent>().listen((event) async {
      //WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (mounted) {
        await context.read<OrdersHistoryProvider>().getActiveOrders();
      }
      //});
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await context.read<LocationProvider>().getUserCountry();
      if (mounted) {
        deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          AndroidDeviceInfo? androidInfo = await deviceInfo?.androidInfo;
          _sistemVersion = 'Android ${androidInfo?.version.release ?? ''}';
          final deviceMarketingNames = DeviceMarketingNames();
          singleDeviceNameFromModel =
              deviceMarketingNames.getSingleNameFromModel(
                  DeviceType.android, '${androidInfo?.model}');
          _device =
              '${StringHelper.capitalize(androidInfo?.brand)} ${singleDeviceNameFromModel == "Unknown" ? androidInfo?.model : singleDeviceNameFromModel}';
          // print(singleDeviceNameFromModel);
        } else if (Platform.isIOS) {
          IosDeviceInfo? iosInfo = await deviceInfo?.iosInfo;
          var _i = await deviceInfo?.deviceInfo;
          _sistemVersion = 'iOS ${iosInfo?.systemVersion ?? ''}';

          _device = '${iosInfo?.utsname.machine?.iOSProductName ?? ''}';
        }

        // _sistemVersion = Platform.isAndroid?  deviceInfo.androidInfo.

        packageInfo = await PackageInfo.fromPlatform();
        await context.read<OrdersHistoryProvider>().getActiveOrders();
      }
    });

    phoneController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (getTabNavItem != null) if (getTabNavItem!.call() !=
    //     BottomNavItem.profile) return Container();
    if (!_isInit) {
      provider = context.read<AppProvider>();
      locProvider = context.watch<LocationProvider>();
      _ordersHistoryProvider = context.watch<OrdersHistoryProvider>();
      _isInit = true;
    }

    phoneController.updateText(widget.profile.phone!);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          if (widget.profile.email == null) {
                            await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ProfileFirstTimePage(
                                    callFromRoute: RoutePaths.profile,
                                    //productId: widget.productId,
                                    phone: widget.profile.phone!,
                                  ),
                                ));
                          } else {
                            var tmp = await navigator?.pushNamed(
                                RoutePaths.personalData,
                                arguments: widget.profile);
                            print('${tmp}');
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AutoSizeText(
                                    '${(widget.profile.name ?? '').isNotEmpty ? widget.profile.name : '${("Your").tr()} ${("Name").tr()}'}${widget.profile.surname == null ? '' : ' ' + widget.profile.surname!}',
                                    minFontSize: 12,
                                    maxFontSize: 20,
                                    style: getTextStyle(fontSize: 20.0),
                                    wrapWords: true,
                                    maxLines: 2,
                                  ),
                                  // Text(
                                  //   '${snapshot.data?.name ?? 'Ваше имя'} ${snapshot.data?.surname ?? ''}',
                                  //   style: getTextStyle(fontSize: 20.0),
                                  // ),
                                  const SizedBox(height: 4.0),
                                  widget.profile.phone != null
                                      ? Text(
                                          phoneController.text,
                                          style: getTextStyle(
                                              fontSize: 14.0,
                                              color: lightBrownColor),
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                            CustomImageWidget(
                              'assets/24/edit.png',
                              width: 24.0,
                              height: 24.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ExpandedSection(
                      child: UserOrders(
                          dataList: _ordersHistoryProvider?.activeOrders ?? []),
                      expand:
                          (_ordersHistoryProvider?.activeOrders.length ?? 0) >
                              0,
                    ),
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(children: [
                        //----- City and Country ----//
                        IconTextArrowItem(
                          data: {
                            'title': locProvider?.currentCity?.title == null ||
                                    (locProvider?.currentCity?.title?.isEmpty ??
                                        false) ||
                                    locProvider?.currentProfile?.country ==
                                        null ||
                                    (locProvider?.currentProfile?.country
                                            ?.isEmpty ??
                                        false)
                                ? '${("Select a city").tr()}'
                                : '${locProvider?.currentCity?.title}, ${locProvider?.currentProfile?.country ?? ''}',
                            'icon': '',
                            'jumpTo': ''
                          },
                          onTap: () async {
                            // Navigator.pushNamed(context, RoutePaths.cityPage);
                            await Navigator.push(context, CupertinoPageRoute(
                              builder: (context) {
                                return CommonCityPage();
                              },
                            ));
                            await context
                                .read<LocationProvider>()
                                .getUserCountry();
                            // if (appSession?.profile?.city?.id !=
                            //     locProvider.currentCity?.id) {
                            //   provider.patchProfile(
                            //       city: locProvider.currentCity);
                            // }
                            setState(() {});
                          },
                        ),
                        //----- History order ----//
                        IconTextArrowItem(
                          data: {
                            'icon': 'assets/24/Timer.png',
                            'title': ("Order history").tr(),
                            'jumpTo': ''
                          },
                          onTap: () {
                            navigator?.pushNamed(RoutePaths.historyOrder);
                          },
                        ),
                        //----- My Adress ----//
                        // IconTextArrowItem(
                        //   data: {
                        //     'icon': 'assets/24/pin_small.png',
                        //     'title': 'Мои адреса',
                        //     'jumpTo': ''
                        //   },
                        //   onTap: () {
                        //     // Navigator.pushNamed(context, RoutePaths.historyOrder);
                        //   },
                        // ),
                        //----- Set Notification ----//
                        IconTextArrowItem(
                          data: {
                            'icon': 'assets/24/Notifications.png',
                            'title': ("Notification settings").tr(),
                            'jumpTo': '${RoutePaths.profileNotificationSetting}'
                          },
                          onTap: () {
                            navigator?.pushNamed(
                                RoutePaths.profileNotificationSetting,
                                arguments: widget.profile);
                          },
                        ),
                        //----- INFORMATIN ----//
                        IconTextArrowItem(
                          data: {
                            'icon': 'assets/24/info.png',
                            'title': ("About us").tr(),
                            'jumpTo': '${RoutePaths.profileInformation}'
                          },
                          onTap: () async {
                            if (!isOpening) {
                              isOpening = true;
                              final appProvider = context.read<AppProvider>();
                              await appProvider.loadAboutPage();
                              await handleInfoPageType(appProvider.about!);
                              isOpening = false;
                            }
                          },
                        ),
                        //----- FORM callback ----//
                        IconTextArrowItem(
                          data: {
                            'icon': 'assets/24/list-checkmark.png',
                            'title': ("F.A.Q").tr(),
                            'jumpTo': '${RoutePaths.profileInformation}',
                          },
                          onTap: () async {
                            await navigator
                                ?.pushNamed(RoutePaths.profileInformation);
                            await provider.getProfile();
                            await context
                                .read<OrdersHistoryProvider>()
                                .getActiveOrders();
                            await context
                                .read<LocationProvider>()
                                .getUserCountry();
                          },
                        ),
                        //----- Chat ----//
                        IconTextArrowItem(
                          data: {
                            'icon': 'assets/24/Chat.png',
                            'title': ("Contact us").tr(),
                            'jumpTo': ''
                          },
                          onTap: () async {
                            await navigator
                                ?.pushNamed(RoutePaths.profileFeedbackPage);
                            // Navigator.pushNamed(context, RoutePaths.historyOrder);
                          },
                        ),
                      ]),
                    ),
                    const SizedBox(height: 76.0),
                    Text(
                      '${("Version").tr()} ${packageInfo?.version ?? ''}',
                      style: getTextStyle(
                        fontSize: 12.0,
                        color: lightBrownColor,
                        height: 18 / 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${("Version OC").tr()} $_sistemVersion',
                      style: getTextStyle(
                        fontSize: 12.0,
                        color: lightBrownColor,
                        height: 18 / 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${("Model").tr()} $_device',
                      style: getTextStyle(
                        fontSize: 12.0,
                        color: lightBrownColor,
                        height: 18 / 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      // ),
    );
  }
}
