.PHONY: setup
setup:
	@flutter clean
	@flutter pub get

.PHONY: br
br:
	@flutter pub run build_runner watch --delete-conflicting-outputs