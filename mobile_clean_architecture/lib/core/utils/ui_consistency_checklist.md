# UI Consistency Checklist

## For Each New Screen:
- [ ] Uses appropriate screen template (Feature Home, Practice Activity, or Results/Feedback)
- [ ] Implements responsive layout for portrait and landscape
- [ ] Uses standard animation patterns for transitions
- [ ] Text elements use TextStyles class for typography
- [ ] Uses AppColors for all color values
- [ ] Follows padding and spacing guidelines from ResponsiveLayout utilities

## For Each New Component:
- [ ] Follows card architecture pattern if applicable
- [ ] Uses consistent spacing from UIConfig
- [ ] Uses AppColors for all color values
- [ ] Touch targets meet minimum size requirements (44dp)
- [ ] Includes accessibility annotations
- [ ] Handles both light and dark modes appropriately

## For Microphone Interactions:
- [ ] Uses standard MicButton component
- [ ] Implements consistent recording states
- [ ] Provides appropriate visual feedback during recording
- [ ] Includes error handling for recording failures
- [ ] Uses VoiceInput component for text display/editing

## For Navigation:
- [ ] Uses standard transition animations from AppPageTransitions
- [ ] Back button consistently placed at top left
- [ ] Primary actions consistently placed at bottom
- [ ] Preserves state appropriately when navigating
- [ ] Uses GoRouter for consistent navigation patterns

## For Cards and Lists:
- [ ] Cards use AppCard component with consistent styling
- [ ] List items maintain consistent spacing
- [ ] Hover and press states provide visual feedback
- [ ] Empty states handled consistently

## For Buttons:
- [ ] Primary actions use PrimaryButton component
- [ ] Secondary actions use SecondaryButton component
- [ ] Icon buttons use standard size and padding
- [ ] Loading states handled consistently
- [ ] Disabled states visually distinct

## For Forms and Inputs:
- [ ] Text inputs use AppTextInput component
- [ ] Validation errors displayed consistently
- [ ] Required fields marked consistently
- [ ] Focus states provide clear visual feedback

## For Feedback Elements:
- [ ] Uses FeedbackCard component with appropriate type
- [ ] Error states use consistent visual language
- [ ] Success celebrations use same visual treatment
- [ ] Instructional text follows voice guidelines from design system

## For Animation:
- [ ] Uses standard duration values from UIConfig
- [ ] Transitions follow natural movement patterns
- [ ] Loading indicators consistent across app
- [ ] Animation not interfering with usability

## For Accessibility:
- [ ] Color contrast meets WCAG AA standards (4.5:1 for text)
- [ ] Interactive elements have minimum 44dp touch target
- [ ] Semantic labels added to all UI elements
- [ ] Text scales appropriately with system settings

## For Performance:
- [ ] Animations run at 60fps
- [ ] Image assets properly optimized
- [ ] Minimal rebuilds of widget tree
- [ ] Widget reuse through component library
