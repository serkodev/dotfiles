# fix universal clipboard
fixcb() {
  echo "Resetting Universal Clipboard / Handoff..."

  defaults -currentHost write com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool false
  defaults -currentHost write com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool false

  sleep 2

  defaults -currentHost write com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool true
  defaults -currentHost write com.apple.coreservices.useractivityd ActivityReceivingAllowed -bool true

  killall useractivityd 2>/dev/null
  killall sharingd 2>/dev/null
  killall pboard 2>/dev/null

  echo "Done. Try copy/paste again."
}
