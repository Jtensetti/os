// Fokus: a pomodoro timer. State lives in localStorage (key fokus:v1).
const KEY = 'fokus:v1';
const total = 25 * 60;
const state = JSON.parse(localStorage.getItem(KEY) || 'null') || { left: 17 * 60 + 42, running: true };
const arc = document.getElementById('arc');
const len = 2 * Math.PI * 132;
arc.style.strokeDasharray = len;

function render() {
  const m = String(Math.floor(state.left / 60)).padStart(2, '0');
  const s = String(state.left % 60).padStart(2, '0');
  document.getElementById('t').textContent = `${m}:${s}`;
  arc.style.strokeDashoffset = len * (state.left / total);
  document.getElementById('go').textContent = state.running ? 'Pausa' : 'Starta';
  localStorage.setItem(KEY, JSON.stringify(state));
}
document.getElementById('go').onclick = () => { state.running = !state.running; render(); };
setInterval(() => { if (state.running && state.left > 0) { state.left--; render(); } }, 1000);
render();
