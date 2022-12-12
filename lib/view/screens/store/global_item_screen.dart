import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/controller/splash_controller.dart';
import 'package:sixam_mart_store/controller/store_controller.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/view/base/custom_app_bar.dart';
import 'package:sixam_mart_store/view/base/custom_button.dart';
import 'package:sixam_mart_store/view/base/custom_snackbar.dart';
import 'package:sixam_mart_store/view/base/item_shimmer.dart';
import 'package:sixam_mart_store/view/base/item_widget.dart';
import 'package:sixam_mart_store/view/screens/store/widget/veg_filter_widget.dart';

class GlobalItemScreen extends StatefulWidget {
  const GlobalItemScreen({Key key}) : super(key: key);

  @override
  State<GlobalItemScreen> createState() => _GlobalItemScreenState();
}

class _GlobalItemScreenState extends State<GlobalItemScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<StoreController>().getGlobalItemList('1', 'all', notify: false);
    Get.find<StoreController>().setGlobalOffset(1);

    scrollController?.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          Get.find<StoreController>().globalItemList != null &&
          !Get.find<StoreController>().isLoading) {
        int pageSize = (Get.find<StoreController>().globalPageSize / 10).ceil();
        if (Get.find<StoreController>().globalOffset < pageSize) {
          Get.find<StoreController>()
              .setOffset(Get.find<StoreController>().globalOffset + 1);
          print('end of the page');
          Get.find<StoreController>().showBottomLoader();
          Get.find<StoreController>().getGlobalItemList(
            Get.find<StoreController>().globalOffset.toString(),
            Get.find<StoreController>().type,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'global_items'.tr),
      body: GetBuilder<StoreController>(builder: (storeController) {
        return Column(children: [
          Expanded(
              child: SingleChildScrollView(
            controller: scrollController,
            child: Column(children: [
              Get.find<SplashController>().configModel.toggleVegNonVeg
                  ? VegFilterWidget(
                      type: storeController.type,
                      onSelected: (String type) =>
                          storeController.getGlobalItemList('1', type),
                    )
                  : SizedBox(),
              storeController.globalItemList != null
                  ? storeController.globalItemList.length > 0
                      ? GridView.builder(
                          key: UniqueKey(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: Dimensions.PADDING_SIZE_LARGE,
                            mainAxisSpacing: 0.01,
                            childAspectRatio: 4,
                            crossAxisCount: 1,
                          ),
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: storeController.globalItemList.length,
                          padding:
                              EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                          itemBuilder: (context, index) {
                            return Row(children: [
                              Checkbox(
                                value: storeController.selectedGlobalItemList
                                    .contains(index),
                                onChanged: (bool isChecked) => storeController
                                    .toggleGlobalSelection(index),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              Expanded(
                                  child: ItemWidget(
                                item: storeController.globalItemList[index],
                                fromGlobal: true,
                                index: index,
                                length: storeController.globalItemList.length,
                                isCampaign: false,
                                inStore: true,
                              )),
                            ]);
                          },
                        )
                      : Center(child: Text('no_item_available'.tr))
                  : GridView.builder(
                      key: UniqueKey(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: Dimensions.PADDING_SIZE_LARGE,
                        mainAxisSpacing: 0.01,
                        childAspectRatio: 4,
                        crossAxisCount: 1,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 20,
                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      itemBuilder: (context, index) {
                        return ItemShimmer(
                          isEnabled: storeController.globalItemList == null,
                          hasDivider: index != 19,
                        );
                      },
                    ),
              storeController.isLoading
                  ? Center(
                      child: Padding(
                      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor)),
                    ))
                  : SizedBox(),
            ]),
          )),
          !storeController.scheduleLoading
              ? CustomButton(
                  buttonText: 'add_to_store'.tr,
                  margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  onPressed: () {
                    if (storeController.selectedGlobalItemList.length == 0) {
                      showCustomSnackBar('select_at_least_one_item'.tr);
                    } else {
                      List<int> _idList = [];
                      for (int index
                          in storeController.selectedGlobalItemList) {
                        _idList.add(storeController.globalItemList[index].id);
                      }
                      storeController.addGlobalItems(_idList);
                    }
                  },
                )
              : Center(child: CircularProgressIndicator()),
        ]);
      }),
    );
  }
}
