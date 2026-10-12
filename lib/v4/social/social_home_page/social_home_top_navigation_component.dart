import 'package:amity_uikit_beta_service/l10n/localization_helper.dart';
import 'package:amity_uikit_beta_service/v4/core/base_component.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:amity_uikit_beta_service/v4/social/community/community_creation/community_setup_page.dart';
import 'package:amity_uikit_beta_service/v4/social/social_home_page/create_post_menu_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AmitySocialHomeTopNavigationComponent extends NewBaseComponent {
  final AmitySocialHomePageTab selectedTab;
  final void Function()? searchButtonAction;

  /// Shows a back button before the title when set.
  final VoidCallback? onBackTap;

  /// Shows a chat button after search when set.
  final VoidCallback? onChatTap;

  /// Unread count shown on the chat button. Zero shows nothing.
  final int chatUnreadCount;

  AmitySocialHomeTopNavigationComponent({
    Key? key,
    String? pageId,
    required this.selectedTab,
    this.searchButtonAction,
    this.onBackTap,
    this.onChatTap,
    this.chatUnreadCount = 0,
  }) : super(key: key, pageId: pageId, componentId: 'top_navigation');

  @override
  Widget buildComponent(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: onBackTap == null
          ? null
          : IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: theme.baseColor,
              ),
              onPressed: onBackTap,
            ),
      titleSpacing: onBackTap == null ? null : 0,
      title: Text(
        context.l10n.community_title,
        style: TextStyle(
          fontSize: 20,
          color: theme.baseColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      backgroundColor: theme.backgroundColor,
      elevation: 0,
      actions: [
        IconButton(
          padding: EdgeInsets.only(right: selectedTab == AmitySocialHomePageTab.explore ? 16 : 0),
          icon: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.secondaryColor.blend(ColorBlendingOption.shade4),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(5),
            child: SvgPicture.asset(
              'assets/Icons/amity_ic_search_button.svg',
              package: 'amity_uikit_beta_service',
              width: 21,
              height: 21,
              colorFilter: ColorFilter.mode(
                theme.secondaryColor,
                BlendMode.srcIn,
              ),
            ),
          ),
          onPressed: () {
            if (searchButtonAction != null) {
              searchButtonAction!();
            }
          },
        ),
        if (onChatTap != null)
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        theme.secondaryColor.blend(ColorBlendingOption.shade4),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(7),
                  // Amity's solid bubble, tinted like the search icon.
                  child: SvgPicture.asset(
                    'assets/Icons/ic_message_bubble_gray.svg',
                    package: 'amity_uikit_beta_service',
                    colorFilter: ColorFilter.mode(
                      theme.secondaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                if (chatUnreadCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    // Height equals minWidth: a circle for one digit.
                    child: Container(
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(minWidth: 18),
                      decoration: BoxDecoration(
                        color: theme.alertColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        chatUnreadCount > 99 ? '99+' : '$chatUnreadCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          height: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: onChatTap,
          ),
        if (selectedTab == AmitySocialHomePageTab.newsFeed)
          AmityCreatePostMenuComponent(),
        if (selectedTab == AmitySocialHomePageTab.myCommunities)
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) =>
                    AmityCommunitySetupPage(mode: const CreateMode()))),
            child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.secondaryColor
                          .blend(ColorBlendingOption.shade4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                        child: SvgPicture.asset(
                      "assets/Icons/amity_ic_post_creation_button.svg",
                      package: 'amity_uikit_beta_service',
                      colorFilter: ColorFilter.mode(
                        theme.secondaryColor,
                        BlendMode.srcIn,
                      ),
                    )))),
          ),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }
}

enum AmitySocialHomePageTab {
  newsFeed,
  explore,
  myCommunities,
}
