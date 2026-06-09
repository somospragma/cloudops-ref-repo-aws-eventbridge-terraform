# Changelog

## [Unreleased]

## [1.0.1] - 2026-06-09
### Added
- SNS target support via `sns_rules` variable (`aws_cloudwatch_event_rule.sns` + `aws_cloudwatch_event_target.sns`)
- `sns_rules` output exposing rule names and ARNs
- `configuration_aliases = [aws.project]` in providers.tf for proper provider injection

## [1.0.0] - 2025-12-10
### Added
- Initial release
- EventBridge rules with Lambda targets (`event_rules`, `scheduled_rules`)
- Optional custom event bus (`create_custom_bus`)
- Optional Dead Letter Queue (`create_dlq`)
- Lambda permissions for EventBridge invocation
