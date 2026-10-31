import 'package:flutter/cupertino.dart';
import '../../../shared/widgets/liquid_glass_sheet.dart';
import '../domain/platform_regions.dart';

Future<({String province, String city})?> showPlatformRegionPicker(
  BuildContext context,
  List<MusicRegion> regions, {
  String? province,
  String? city,
}) => showLiquidGlassBottomSheet<({String province, String city})>(
  context: context,
  useRootNavigator: true,
  useSafeArea: true,
  builder: (_) =>
      _RegionPicker(regions: regions, province: province, city: city),
);

class _RegionPicker extends StatefulWidget {
  const _RegionPicker({required this.regions, this.province, this.city});
  final List<MusicRegion> regions;
  final String? province, city;
  @override
  State<_RegionPicker> createState() => _RegionPickerState();
}

class _RegionPickerState extends State<_RegionPicker> {
  late final List<MusicRegion> _regions;
  late final FixedExtentScrollController _provinces, _cities;
  late int _province, _city;
  @override
  void initState() {
    super.initState();
    _regions = [...widget.regions];
    _province = _regions.indexWhere(
      (p) => p.name == widget.province || p.code == widget.province,
    );
    if (_province < 0 && widget.province?.isNotEmpty == true) {
      // Preserve an existing overseas/legacy region even when it is outside
      // this offline mainland data set. Merely opening the picker writes none.
      _regions.insert(
        0,
        MusicRegion(widget.province!, '', [
          (name: widget.city ?? widget.province!, code: ''),
        ]),
      );
      _province = 0;
    }
    if (_province < 0) _province = 0;
    _city = _regions[_province].cities.indexWhere(
      (c) => c.name == widget.city || c.code == widget.city,
    );
    if (_city < 0) _city = 0;
    _provinces = FixedExtentScrollController(initialItem: _province);
    _cities = FixedExtentScrollController(initialItem: _city);
  }

  @override
  void dispose() {
    _provinces.dispose();
    _cities.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CupertinoButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              const Expanded(
                child: Text(
                  '选择地区',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              CupertinoButton(
                onPressed: () => Navigator.pop(context, (
                  province: _regions[_province].name,
                  city: _regions[_province].cities[_city].name,
                )),
                child: const Text('完成'),
              ),
            ],
          ),
          SizedBox(
            height: 240,
            child: Row(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _provinces,
                    itemExtent: 42,
                    onSelectedItemChanged: (value) {
                      setState(() {
                        _province = value;
                        _city = 0;
                      });
                      if (_cities.hasClients) _cities.jumpToItem(0);
                    },
                    children: [
                      for (final region in _regions)
                        Center(
                          child: Text(
                            region.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: _cities,
                    itemExtent: 42,
                    onSelectedItemChanged: (value) => _city = value.clamp(
                      0,
                      _regions[_province].cities.length - 1,
                    ),
                    children: [
                      for (final city in _regions[_province].cities)
                        Center(
                          child: Text(
                            city.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
