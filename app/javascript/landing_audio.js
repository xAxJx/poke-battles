const STORAGE_KEY = "pokeBattlesSoundOn";

const initLandingAudio = () => {
  const root = document.querySelector("[data-landing-audio]");
  if (!root) return;

  const confirmUrl = root.dataset.confirmUrl;
  const ambientUrl = root.dataset.ambientUrl;
  const toggle = root.querySelector("[data-sound-toggle]");
  const label = root.querySelector("[data-sound-label]");
  const startLink = root.querySelector("[data-sound='confirm']");

  if (!confirmUrl || !ambientUrl || !toggle || !label) return;

  const confirmAudio = new Audio(confirmUrl);
  confirmAudio.preload = "auto";
  confirmAudio.volume = 0.4;

  const ambientAudio = new Audio(ambientUrl);
  ambientAudio.preload = "auto";
  ambientAudio.loop = true;
  ambientAudio.volume = 0.12;

  let soundOn = localStorage.getItem(STORAGE_KEY) === "true";

  const setToggleUI = (enabled) => {
    toggle.classList.toggle("is-on", enabled);
    toggle.setAttribute("aria-pressed", enabled ? "true" : "false");
    label.textContent = enabled ? "Sound On" : "Sound Off";
  };

  setToggleUI(soundOn);

  let pendingAmbient = soundOn;
  const startAmbient = () => {
    if (!soundOn) return;
    ambientAudio.currentTime = 0;
    ambientAudio.play().catch(() => {});
    pendingAmbient = false;
  };

  if (pendingAmbient) {
    const armAmbient = () => {
      if (pendingAmbient) startAmbient();
    };
    document.addEventListener("pointerdown", armAmbient, { once: true });
    document.addEventListener("keydown", armAmbient, { once: true });
  }

  toggle.addEventListener("click", () => {
    soundOn = !soundOn;
    localStorage.setItem(STORAGE_KEY, soundOn ? "true" : "false");
    setToggleUI(soundOn);

    if (soundOn) {
      startAmbient();
    } else {
      pendingAmbient = false;
      ambientAudio.pause();
      ambientAudio.currentTime = 0;
    }
  });

  if (startLink) {
    startLink.addEventListener("click", () => {
      if (!soundOn) return;
      confirmAudio.currentTime = 0;
      confirmAudio.play().catch(() => {});
    });
  }
};

document.addEventListener("turbo:load", initLandingAudio);
