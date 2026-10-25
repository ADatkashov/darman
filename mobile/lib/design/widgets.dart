import 'package:flutter/material.dart';

import '../core/network/api_failure.dart';
import '../core/theme/colors.dart';
import '../core/theme/spacing.dart';
import '../core/utils/error_text.dart';
import '../core/utils/formatters.dart';
import '../data/models/catalog_models.dart';
import '../l10n/l10n_ext.dart';
import 'category_icons.dart';
import 'product_image.dart';

// ───────────────────────── layout helpers ─────────────────────────

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.padding = const EdgeInsets.fromLTRB(Sp.gutter, Sp.x6, Sp.gutter, Sp.x3),
  });
  final String title;
  final VoidCallback? onSeeAll;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      children: [
        Expanded(
          child: Semantics(header: true, child: Text(title, style: context.text.titleMedium)),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 40),
              padding: const EdgeInsets.symmetric(horizontal: Sp.x2),
            ),
            child: Text(context.l10n.seeAll, style: context.text.labelMedium?.copyWith(color: context.scheme.primary)),
          ),
      ],
    ),
  );
}

/// Rounded surface with a hairline border (the app's standard card).
class DmCard extends StatelessWidget {
  const DmCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Sp.x4),
    this.onTap,
    this.color,
    this.radius = Sp.radiusLg,
  });
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: context.dm.cardBorder),
    );
    return Material(
      color: color ?? Theme.of(context).cardTheme.color,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, this.color, this.background, this.icon});
  final String label;
  final Color? color;
  final Color? background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.x2 + 2, vertical: 3),
      decoration: BoxDecoration(color: background ?? fg.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(Sp.radiusPill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              style: context.text.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: Sp.x4, vertical: compact ? Sp.x1 + 2 : Sp.x2 + 2),
    color: DmPalette.warning.withValues(alpha: 0.18),
    child: Row(
      children: [
        const Icon(Icons.science_outlined, size: 16, color: Color(0xFF8A5A00)),
        const SizedBox(width: Sp.x2),
        Expanded(
          child: Text(
            context.l10n.demoModeBanner,
            style: context.text.labelSmall?.copyWith(
              color: context.scheme.brightness == Brightness.light ? const Color(0xFF6B4500) : DmPalette.warning,
            ),
          ),
        ),
      ],
    ),
  );
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: context.scheme.error,
    padding: const EdgeInsets.symmetric(vertical: Sp.x1 + 2, horizontal: Sp.x4),
    child: Row(
      children: [
        Icon(Icons.wifi_off, size: 16, color: context.scheme.onError),
        const SizedBox(width: Sp.x2),
        Expanded(
          child: Text(context.l10n.offlineBanner, style: context.text.labelMedium?.copyWith(color: context.scheme.onError)),
        ),
      ],
    ),
  );
}

// ───────────────────────── states ─────────────────────────

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.actionLabel, this.onAction});
  final IconData icon;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(Sp.x8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: context.dm.softMint, shape: BoxShape.circle),
            child: Icon(icon, size: 44, color: context.scheme.primary),
          ),
          const SizedBox(height: Sp.x5),
          Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
          if (body != null) ...[
            const SizedBox(height: Sp.x2),
            Text(
              body!,
              style: context.text.bodyMedium?.copyWith(color: context.dm.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: Sp.x6),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    ),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final offline = error is ApiFailure && (error as ApiFailure).isNetwork;
    return EmptyState(
      icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: errorText(l, error),
      actionLabel: onRetry == null ? null : l.retry,
      onAction: onRetry,
    );
  }
}

/// Pulsing placeholder block used for skeleton loading states.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height = 16, this.radius = 8});
  final double? width;
  final double height;
  final double radius;
  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final base = context.dm.softMint;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(base, base.withValues(alpha: 0.45), reduce ? 0 : _c.value),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key, this.width = 156});
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: DmCard(
      padding: const EdgeInsets.all(Sp.x3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: width - Sp.x3 * 2 - 2, height: 96, radius: 14),
          const SizedBox(height: Sp.x3),
          const Skeleton(height: 12),
          const SizedBox(height: Sp.x2),
          const Skeleton(width: 80, height: 12),
          const SizedBox(height: Sp.x3),
          const Skeleton(width: 60, height: 16),
        ],
      ),
    ),
  );
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.count = 5});
  final int count;
  @override
  Widget build(BuildContext context) => ListView.separated(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(Sp.gutter),
    itemCount: count,
    separatorBuilder: (_, _) => const SizedBox(height: Sp.x3),
    itemBuilder: (_, _) => const DmCard(
      child: Row(
        children: [
          Skeleton(width: 80, height: 80, radius: 14),
          SizedBox(width: Sp.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 14),
                SizedBox(height: Sp.x2),
                Skeleton(width: 120, height: 12),
                SizedBox(height: Sp.x4),
                Skeleton(width: 70, height: 16),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ───────────────────────── product widgets ─────────────────────────

class PriceText extends StatelessWidget {
  const PriceText({super.key, required this.price, this.oldPrice, this.style, this.prefix});
  final double price;
  final double? oldPrice;
  final TextStyle? style;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final loc = context.localeCode;
    final main = style ?? context.text.titleMedium!;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: Sp.x2,
      children: [
        Text('${prefix ?? ''}${formatMoney(price, loc)}', style: main.copyWith(color: oldPrice != null ? context.scheme.error : null)),
        if (oldPrice != null && oldPrice! > price)
          Text(
            formatMoney(oldPrice!, loc),
            style: context.text.bodySmall?.copyWith(decoration: TextDecoration.lineThrough, color: context.dm.textSecondary),
          ),
      ],
    );
  }
}

class StockPill extends StatelessWidget {
  const StockPill({super.key, required this.availability, this.count});
  final Availability availability;
  final int? count;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return switch (availability) {
      Availability.inStock => Pill(label: l.stockIn, color: context.dm.success, icon: Icons.check_circle_outline),
      Availability.lowStock => Pill(
        label: count != null ? l.stockCount(count!) : l.stockLow,
        color: const Color(0xFF9A6200),
        background: DmPalette.warning.withValues(alpha: 0.2),
        icon: Icons.timelapse,
      ),
      Availability.outOfStock => Pill(label: l.stockOut, color: context.scheme.error, icon: Icons.block),
    };
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.active, required this.onPressed, this.size = 22});
  final bool active;
  final VoidCallback onPressed;
  final double size;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return IconButton(
      onPressed: onPressed,
      tooltip: active ? l.favoriteRemove : l.favoriteAdd,
      icon: Icon(
        active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        size: size,
        color: active ? context.scheme.error : context.dm.textSecondary,
      ),
    );
  }
}

/// Round add-to-cart button used on cards.
class AddRoundButton extends StatelessWidget {
  const AddRoundButton({super.key, required this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l10n.addToCart,
    child: SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: Material(
          color: onPressed == null ? context.dm.divider : context.scheme.primary,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: SizedBox(width: 36, height: 36, child: Icon(Icons.shopping_cart_outlined, size: 19, color: context.scheme.onPrimary)),
          ),
        ),
      ),
    ),
  );
}

/// Vertical product card for horizontal carousels (consistent 156 × 236 dimensions).
class ProductTile extends StatelessWidget {
  const ProductTile({super.key, required this.product, required this.onTap, this.onAdd, this.width = 156});
  final ProductCard product;
  final VoidCallback onTap;
  final VoidCallback? onAdd;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SizedBox(
      width: width,
      child: DmCard(
        onTap: onTap,
        padding: const EdgeInsets.all(Sp.x3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ProductImage(
                  categorySlug: product.categorySlug,
                  form: product.dosageForm,
                  label: product.brand,
                  imageUrl: product.imageUrl,
                  size: width - Sp.x3 * 2 - 2,
                  radius: 14,
                  semanticLabel: product.name,
                ),
                if (product.rxRequired)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Pill(label: l.badgeRx, color: Colors.white, background: context.scheme.primary),
                  ),
              ],
            ),
            const SizedBox(height: Sp.x2),
            Text(product.name, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(product.specLine, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: product.price == null
                      ? Text(l.stockOut, style: context.text.labelMedium?.copyWith(color: context.scheme.error))
                      : PriceText(price: product.price!, oldPrice: product.oldPrice, style: context.text.titleSmall),
                ),
                if (onAdd != null && product.inStock && product.bestOfferId != null) AddRoundButton(onPressed: onAdd),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal row used in search results / favorites.
class ProductRow extends StatelessWidget {
  const ProductRow({super.key, required this.product, required this.onTap, this.onAdd, this.trailing});
  final ProductCard product;
  final VoidCallback onTap;
  final VoidCallback? onAdd;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DmCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Sp.x3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(
            categorySlug: product.categorySlug,
            form: product.dosageForm,
            label: product.brand,
            imageUrl: product.imageUrl,
            size: 84,
            radius: 14,
            semanticLabel: product.name,
          ),
          const SizedBox(width: Sp.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                if (product.specLine.isNotEmpty)
                  Text(product.specLine, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (product.pharmacyName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(product.pharmacyName!, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                const SizedBox(height: Sp.x2),
                Wrap(
                  spacing: Sp.x2,
                  runSpacing: 4,
                  children: [
                    if (product.rxRequired) Pill(label: l.badgeRx, color: context.scheme.primary),
                    Pill(
                      label: product.inStock ? l.stockIn : l.stockOut,
                      color: product.inStock ? context.dm.success : context.scheme.error,
                      icon: product.inStock ? Icons.check_circle_outline : Icons.block,
                    ),
                  ],
                ),
                const SizedBox(height: Sp.x2),
                Row(
                  children: [
                    Expanded(
                      child: product.price == null
                          ? const SizedBox.shrink()
                          : product.availableOffers > 1
                          ? Text(l.priceFrom(formatMoney(product.price!, context.localeCode)), style: context.text.titleMedium)
                          : PriceText(price: product.price!, oldPrice: product.oldPrice),
                    ),
                    ?trailing,
                    if (onAdd != null && product.inStock && product.bestOfferId != null) AddRoundButton(onPressed: onAdd),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category, required this.onTap});
  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 84,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Sp.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sp.x1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: context.dm.softMint, borderRadius: BorderRadius.circular(20)),
              child: Icon(categoryIcon(category.icon), color: context.scheme.primary, size: 28),
            ),
            const SizedBox(height: Sp.x2),
            Text(category.name, style: context.text.labelSmall, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    ),
  );
}

// ───────────────────────── quantity ─────────────────────────

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key, required this.quantity, required this.onChanged, this.min = 1, this.max = 99});
  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget btn(IconData icon, String tip, VoidCallback? onTap) => Semantics(
      button: true,
      label: tip,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: onTap == null ? context.dm.divider : context.dm.softMint, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: onTap == null ? context.dm.textSecondary : context.scheme.primary),
            ),
          ),
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.remove, l.quantityDecrease, quantity > min ? () => onChanged(quantity - 1) : null),
        Semantics(
          label: l.quantityLabel(quantity),
          child: SizedBox(
            width: 28,
            child: Text('$quantity', textAlign: TextAlign.center, style: context.text.titleSmall),
          ),
        ),
        btn(Icons.add, l.quantityIncrease, quantity < max ? () => onChanged(quantity + 1) : null),
      ],
    );
  }
}

/// Section with a tinted rounded panel, used for info blocks (delivery, disclaimers).
class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key, required this.icon, required this.text, this.tint});
  final IconData icon;
  final String text;
  final Color? tint;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(Sp.x3 + 2),
    decoration: BoxDecoration(
      color: tint ?? context.dm.paleAqua,
      borderRadius: BorderRadius.circular(Sp.radiusMd),
      border: Border.all(color: context.dm.divider),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: context.scheme.primary),
        const SizedBox(width: Sp.x3),
        Expanded(
          child: Text(text, style: context.text.bodySmall?.copyWith(color: context.scheme.onSurface)),
        ),
      ],
    ),
  );
}

void showSnack(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      content: Text(message),
      action: actionLabel == null ? null : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}, textColor: DmPalette.mint),
    ),
  );
}
