import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nawa/features/interests/domain/interest_category.dart';
import 'package:nawa/features/onboarding/presentation/state/onboarding_controller.dart';
import 'package:nawa/features/profile/presentation/state/child_profile_controller.dart';
import 'package:nawa/features/interests/presentation/state/interest_profile_controller.dart';

void main() {
  group('OnboardingController', () {
    test('setName/setAge/toggleInterest update state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(onboardingProvider.notifier).setName('Layla');
      container.read(onboardingProvider.notifier).setAge(9);
      container.read(onboardingProvider.notifier).toggleInterest(InterestCategoryType.science);

      final state = container.read(onboardingProvider);
      expect(state.childName, 'Layla');
      expect(state.age, 9);
      expect(state.selectedInterests, {InterestCategoryType.science});
      expect(state.canContinueFromName, isTrue);
      expect(state.canContinueFromAge, isTrue);
      expect(state.canContinueFromInterests, isTrue);
    });

    test('toggleInterest twice deselects the category', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(onboardingProvider.notifier);
      notifier.toggleInterest(InterestCategoryType.gaming);
      notifier.toggleInterest(InterestCategoryType.gaming);

      expect(container.read(onboardingProvider).selectedInterests, isEmpty);
    });

    test('complete() applies answers to child profile and interest profile', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(onboardingProvider.notifier);
      notifier.setName('Sara');
      notifier.setAge(7);
      notifier.toggleInterest(InterestCategoryType.art);
      notifier.toggleInterest(InterestCategoryType.sports);
      notifier.complete();

      final onboarding = container.read(onboardingProvider);
      expect(onboarding.completed, isTrue);

      final child = container.read(childProfileProvider);
      expect(child.name, 'Sara');
      expect(child.age, 7);
      expect(child.interests, {InterestCategoryType.art, InterestCategoryType.sports});

      final profile = container.read(interestProfileProvider);
      expect(profile[InterestCategoryType.art]!.score, greaterThan(profile[InterestCategoryType.technology]!.score));
      expect(profile[InterestCategoryType.sports]!.score, greaterThan(profile[InterestCategoryType.technology]!.score));
    });
  });
}
