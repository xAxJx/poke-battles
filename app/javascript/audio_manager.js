const STORAGE_KEY = "pokeBattlesSoundOn";
const VOLUME_KEY = "pokeBattlesVolume";
const DEFAULT_AMBIENT_VOLUME = 0.08;
const DEFAULT_CONFIRM_VOLUME = 0.6;

const audioState = {
  soundOn: localStorage.getItem(STORAGE_KEY) === "true",
  gestureArmed: false
};

const getBgAudio = () => {
  let audio = document.getElementById("bg-audio");
  if (!audio) {
    audio = document.createElement("audio");
    audio.id = "bg-audio";
    audio.setAttribute("data-turbo-permanent", "");
    document.body.appendChild(audio);
  }
  audio.loop = true;
  audio.preload = "auto";
  return audio;
};

const getConfirmAudio = () => {
  if (!window.__pokeBattlesConfirmAudio) {
    window.__pokeBattlesConfirmAudio = new Audio();
    window.__pokeBattlesConfirmAudio.preload = "auto";
  }
  return window.__pokeBattlesConfirmAudio;
};

const readVolume = () => {
  const stored = parseFloat(localStorage.getItem(VOLUME_KEY));
  return Number.isFinite(stored) ? stored : DEFAULT_AMBIENT_VOLUME;
};

const syncToggleUI = (enabled) => {
  document.querySelectorAll("[data-sound-toggle]").forEach((toggle) => {
    toggle.classList.toggle("is-on", enabled);
    toggle.setAttribute("aria-pressed", enabled ? "true" : "false");
    const label = toggle.querySelector("[data-sound-label]");
    if (label) label.textContent = enabled ? "Sound On" : "Sound Off";
  });
};

const armGesture = () => {
  if (audioState.gestureArmed) return;
  audioState.gestureArmed = true;
  const attemptPlay = () => {
    if (!audioState.soundOn) return;
    const bgAudio = getBgAudio();
    if (!bgAudio.src) return;
    bgAudio.play().catch(() => {});
  };
  document.addEventListener("pointerdown", attemptPlay, { once: true });
  document.addEventListener("keydown", attemptPlay, { once: true });
};

const startAmbient = () => {
  const bgAudio = getBgAudio();
  if (!bgAudio.src) return;
  if (!bgAudio.paused) return;
  const playPromise = bgAudio.play();
  if (playPromise) {
    playPromise.catch(() => {
      armGesture();
    });
  }
};

const stopAmbient = () => {
  const bgAudio = getBgAudio();
  bgAudio.pause();
};

const setSoundOn = (enabled) => {
  audioState.soundOn = enabled;
  localStorage.setItem(STORAGE_KEY, enabled ? "true" : "false");
  syncToggleUI(enabled);
  if (enabled) {
    startAmbient();
  } else {
    stopAmbient();
  }
};

const bindToggle = (toggle) => {
  if (!toggle || toggle.dataset.soundBound === "true") return;
  toggle.dataset.soundBound = "true";
  toggle.addEventListener("click", () => {
    setSoundOn(!audioState.soundOn);
  });
};

const bindConfirmTriggers = (confirmUrl) => {
  const confirmAudio = getConfirmAudio();
  if (confirmUrl && confirmAudio.src !== confirmUrl) {
    confirmAudio.src = confirmUrl;
  }
  confirmAudio.volume = DEFAULT_CONFIRM_VOLUME;

  document.querySelectorAll("[data-sound='confirm']").forEach((trigger) => {
    if (trigger.dataset.soundBound === "true") return;
    trigger.dataset.soundBound = "true";
    trigger.addEventListener("click", () => {
      if (!audioState.soundOn || !confirmAudio.src) return;
      confirmAudio.currentTime = 0;
      confirmAudio.play().catch(() => {});
    });
  });
};

const initAudioManager = () => {
  audioState.soundOn = localStorage.getItem(STORAGE_KEY) === "true";
  const root = document.querySelector("[data-landing-audio]");
  const confirmUrl = root?.dataset.confirmUrl;
  const ambientUrl = root?.dataset.ambientUrl;
  const toggle = root?.querySelector("[data-sound-toggle]");

  const bgAudio = getBgAudio();
  bgAudio.volume = readVolume();

  if (ambientUrl && bgAudio.dataset.src !== ambientUrl) {
    bgAudio.src = ambientUrl;
    bgAudio.dataset.src = ambientUrl;
  }

  syncToggleUI(audioState.soundOn);
  bindToggle(toggle);
  bindConfirmTriggers(confirmUrl);

  if (audioState.soundOn) {
    startAmbient();
  } else {
    stopAmbient();
  }
};

document.addEventListener("turbo:load", initAudioManager);
