const overlay = document.getElementById('crosshair-overlay');
const chModern = document.getElementById('ch-modern');
const chClassic = document.getElementById('ch-classic');
const chCustom  = document.getElementById('ch-custom');
const hitLayer  = document.getElementById('hit-layer');

const popup = document.getElementById('popup');
const xClose = document.getElementById('x-close');

/* Tabs */
const tabs = Array.from(document.querySelectorAll('.tab'));
const pageCrosshair = document.getElementById('page-crosshair');
const pageHit = document.getElementById('page-hit');

/* Crosshair preview bits */
const chips = Array.from(document.querySelectorAll('.chip.select'));
const prevNone   = document.getElementById('prev-none');
const prevModern = document.getElementById('prev-modern');
const prevClassic = document.getElementById('prev-classic');
const prevCustom  = document.getElementById('prev-custom');
const customControls = document.getElementById('custom-controls');

/* Hit page elements */
const hitStyleChips = Array.from(document.querySelectorAll('.chip.hitstyle'));
const hitColorInput = document.getElementById('hit-color');
const hitPreviewLayer = document.getElementById('hit-preview-layer');

/* Hit marker inputs */
const halpha = document.getElementById('halpha');
const hthick = document.getElementById('hthick');
const hsize  = document.getElementById('hsize');
const hdur   = document.getElementById('hdur');
const houtline = document.getElementById('houtline');
const houtth = document.getElementById('houtth');
const houta  = document.getElementById('houta');

/* Custom crosshair inputs */
const ccolor  = document.getElementById('ccolor');
const calpha  = document.getElementById('calpha');
const cthick  = document.getElementById('cthick');
const csize   = document.getElementById('csize');
const cgap    = document.getElementById('cgap');
const cdot    = document.getElementById('cdot');
const ctstyle = document.getElementById('ctstyle');
const coutline= document.getElementById('coutline');
const coutth  = document.getElementById('coutth');
const couta   = document.getElementById('couta');
const cdynm   = document.getElementById('cdynm');
const cmovei  = document.getElementById('cmovei');
const cdynf   = document.getElementById('cdynf');
const cfirei  = document.getElementById('cfirei');
const creset  = document.getElementById('creset');

/* Value badges */
const val = (id) => document.getElementById(id);

let currentType = 'modern';
let currentTab = 'crosshair';
let currentPreviewEl = null;

let customCfg = {
  color:{r:60,g:255,b:122}, alpha:1, thickness:2, size:10, gap:6, dot:true, tstyle:false,
  outline:true, outlineThickness:2, outlineAlpha:0.8,
  dynamicMove:true, dynamicFire:true, moveInfluence:0.6, fireInfluence:0.6
};

let hitCfg = { style:'flash', color:{r:60,g:255,b:122}, alpha:1, thickness:3, size:32, outline:true, outlineThickness:2, outlineAlpha:0.8, duration:420 };

/* ---------- Helpers ---------- */
function mapPrev(type){
  if (type === 'modern') return prevModern;
  if (type === 'classic') return prevClassic;
  if (type === 'custom')  return prevCustom;
  return prevNone;
}
function hardShowPreview(type){
  const incoming = mapPrev(type);
  [prevNone,prevModern,prevClassic,prevCustom].forEach(el=>{
    el.classList.add('hidden');
    el.classList.remove('show');
  });
  if (incoming){
    incoming.classList.remove('hidden');
    incoming.classList.add('show');
    currentPreviewEl = incoming;
  }
}

/* ---------- Tabs ---------- */
function switchTab(name){
  if (currentTab === name) return;
  tabs.forEach(t => t.classList.toggle('active', t.dataset.tab === name));
  if (name === 'crosshair'){
    pageHit.classList.add('hidden');
    pageCrosshair.classList.remove('hidden');
  } else {
    pageCrosshair.classList.add('hidden');
    pageHit.classList.remove('hidden');
  }
  currentTab = name;
}
tabs.forEach(t => t.addEventListener('click', () => switchTab(t.dataset.tab)));

/* ---------- Crosshair page ---------- */
function showType(type, opts){
  currentType = type;

  chModern.classList.add('hidden');
  chClassic.classList.add('hidden');
  chCustom.classList.add('hidden');
  if (type === 'modern') chModern.classList.remove('hidden');
  if (type === 'classic') chClassic.classList.remove('hidden');
  if (type === 'custom')  chCustom.classList.remove('hidden');

  if (opts && opts.immediate){
    hardShowPreview(type);
  } else {
    const incoming = mapPrev(type);
    if (!currentPreviewEl){
      hardShowPreview(type);
    } else if (incoming !== currentPreviewEl){
      currentPreviewEl.classList.remove('show');
      currentPreviewEl.classList.add('hidden');
      incoming.classList.remove('hidden');
      incoming.classList.add('show');
      currentPreviewEl = incoming;
    }
  }

  if (type === 'custom'){
    customControls.classList.remove('hidden');
  } else {
    customControls.classList.add('hidden');
  }

  chips.forEach(c => c.classList.toggle('active', c.dataset.type === type));
}
function setEnabled(enabled) {
  overlay.classList.toggle('hidden-init', !enabled);
}
function setActive(active) {
  overlay.style.opacity = active ? '1' : '0';
}

/* ---------- Hit marker ---------- */
function setHitVarsScope(scope, cfg){
  scope.style.setProperty('--hit-r', cfg.color.r);
  scope.style.setProperty('--hit-g', cfg.color.g);
  scope.style.setProperty('--hit-b', cfg.color.b);
  scope.style.setProperty('--hit-a', cfg.alpha);
  scope.style.setProperty('--hm-th', `${cfg.thickness}px`);
  scope.style.setProperty('--hm-size', `${cfg.size}px`);
  scope.style.setProperty('--hm-outTh', `${cfg.outline ? cfg.outlineThickness : 0}px`);
  scope.style.setProperty('--hm-outA', `${cfg.outline ? cfg.outlineAlpha : 0}`);
  scope.style.setProperty('--hm-dur', `${cfg.duration}ms`);
}
function setHitVars(){ setHitVarsScope(overlay, hitCfg); setHitVarsScope(hitLayer, hitCfg); }
function setHitPreviewVars(){ setHitVarsScope(hitPreviewLayer, hitCfg); }

function updateHitPreview(){
  Array.from(hitPreviewLayer.querySelectorAll('.hm')).forEach(el => el.classList.remove('show'));
  if (hitCfg.style === 'none') return;
  const selector =
    hitCfg.style === 'x' ? '.hm.hm-x' :
    hitCfg.style === 'ring' ? '.hm.hm-ring' :
    hitCfg.style === 'dot' ? '.hm.hm-dot' :
    hitCfg.style === 'diamond' ? '.hm.hm-diamond' :
    '.hm.hm-ring';
  const el = hitPreviewLayer.querySelector(selector);
  if (el) el.classList.add('show');
}

function getMarkerElement(root, style){
  switch(style){
    case 'x': return root.querySelector('.hm.hm-x');
    case 'ring': return root.querySelector('.hm.hm-ring');
    case 'dot': return root.querySelector('.hm.hm-dot');
    case 'diamond': return root.querySelector('.hm.hm-diamond');
    case 'flash': default: return root.querySelector('.hm.hm-ring');
  }
}
function pulseMarker(root, style, dur){
  const all = root.querySelectorAll('.hm');
  all.forEach(e => e.classList.remove('run'));
  const el = getMarkerElement(root, style);
  if (!el) return;
  void el.offsetWidth;
  el.classList.add('run');
  setTimeout(() => { el.classList.remove('run'); }, dur);
}

/* Keep crosshair hidden while chaining hits */
let hitHoldUntil = 0;
let hitClearTimer = null;
function ensureHitHoldActive(){
  overlay.classList.add('force-visible');
  overlay.classList.add('hide-ch');
  if (hitClearTimer) return;
  hitClearTimer = setInterval(() => {
    if (Date.now() > hitHoldUntil) {
      overlay.classList.remove('hide-ch');
      overlay.classList.remove('force-visible');
      clearInterval(hitClearTimer);
      hitClearTimer = null;
    }
  }, 20);
}
function playHitMarker(){
  if (hitCfg.style === 'none') return;
  setHitVars();
  const dur = (hitCfg.duration || 420) + 40;
  pulseMarker(document, hitCfg.style, dur);
  hitHoldUntil = Date.now() + dur + 120;
  ensureHitHoldActive();
}

/* ---------- Color helpers ---------- */
function hexToRgb(hex){
  const v = hex.replace('#','');
  const x = v.length === 3 ? v.split('').map(ch => ch+ch).join('') : v;
  const n = parseInt(x,16);
  return { r:(n>>16)&255, g:(n>>8)&255, b:n&255 };
}
function rgbToHex({r,g,b}) {
  const to2 = n => n.toString(16).padStart(2,'0');
  return `#${to2(r)}${to2(g)}${to2(b)}`;
}

/* ---------- Value badge helpers ---------- */
function setBadge(el, text){ if (el) el.textContent = text; }
function setHexBadge(el, rgb){
  const hex = rgbToHex(rgb).toLowerCase();
  if (el) el.textContent = hex;
}

/* ---------- Custom crosshair binding ---------- */
function applyCustom(cfg){
  chCustom.style.setProperty('--c-r', cfg.color.r);
  chCustom.style.setProperty('--c-g', cfg.color.g);
  chCustom.style.setProperty('--c-b', cfg.color.b);
  chCustom.style.setProperty('--alpha', cfg.alpha);
  chCustom.style.setProperty('--thPx', `${cfg.thickness}px`);
  chCustom.style.setProperty('--lenPx', `${cfg.size}px`);
  chCustom.style.setProperty('--gapPx', `${cfg.gap}px`);
  chCustom.style.setProperty('--outThPx', `${cfg.outline ? cfg.outlineThickness : 0}px`);
  chCustom.style.setProperty('--outA', `${cfg.outline ? cfg.outlineAlpha : 0}`);
  chCustom.style.setProperty('--dynGapPx', `${Math.round(8 * Math.max(cfg.moveInfluence, cfg.fireInfluence))}px`);
  chCustom.classList.toggle('nodot', !cfg.dot);
  chCustom.classList.toggle('tstyle', !!cfg.tstyle);

  const rgba = `rgba(${cfg.color.r},${cfg.color.g},${cfg.color.b},${cfg.alpha})`;
  prevCustom.style.setProperty('--c', rgba);
  prevCustom.style.setProperty('--thPx', `${cfg.thickness}px`);
  prevCustom.style.setProperty('--lenPx', `${cfg.size}px`);
  prevCustom.style.setProperty('--gapPx', `${cfg.gap}px`);
  prevCustom.style.setProperty('--outThPx', `${cfg.outline ? cfg.outlineThickness : 0}px`);
  prevCustom.style.setProperty('--outA', `${cfg.outline ? cfg.outlineAlpha : 0}`);
  prevCustom.classList.toggle('nodot', !cfg.dot);
  prevCustom.classList.toggle('tstyle', !!cfg.tstyle);
}
function fillCustomControls(cfg){
  const hex = `#${((1<<24)+(cfg.color.r<<16)+(cfg.color.g<<8)+cfg.color.b).toString(16).slice(1)}`.toLowerCase();
  ccolor.value = hex;
  val('ccolor-val').textContent = hex;
  calpha.value = Math.round((cfg.alpha||1)*100); setBadge(val('calpha-val'), `${calpha.value}%`);
  cthick.value = cfg.thickness; setBadge(val('cthick-val'), `${cthick.value}px`);
  csize.value = cfg.size; setBadge(val('csize-val'), `${csize.value}px`);
  cgap.value = cfg.gap; setBadge(val('cgap-val'), `${cgap.value}px`);
  cdot.checked = !!cfg.dot;
  ctstyle.checked = !!cfg.tstyle;
  coutline.checked = !!cfg.outline;
  coutth.value = cfg.outlineThickness; setBadge(val('coutth-val'), `${coutth.value}px`);
  couta.value = Math.round((cfg.outlineAlpha||0.8)*100); setBadge(val('couta-val'), `${couta.value}%`);
  cdynm.checked = !!cfg.dynamicMove;
  cmovei.value = Math.round((cfg.moveInfluence||0.6)*100); setBadge(val('cmovei-val'), `${cmovei.value}%`);
  cdynf.checked = !!cfg.dynamicFire;
  cfirei.value = Math.round((cfg.fireInfluence||0.6)*100); setBadge(val('cfirei-val'), `${cfirei.value}%`);
}
function pushCustom(update){
  customCfg = { ...customCfg, ...update, color: update.color ? update.color : customCfg.color };
  applyCustom(customCfg);
  fetch(`https://${GetParentResourceName()}/updateCustom`,{
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body: JSON.stringify(customCfg)
  }).catch(()=>{});
}

/* ---------- Hit marker binding ---------- */
function applyHitCfg(cfg){
  hitCfg = cfg;
  setHitVars();
  setHitPreviewVars();
  updateHitPreview();
  hitStyleChips.forEach(c => c.classList.toggle('active', c.dataset.hit === hitCfg.style));
  hitColorInput.value = rgbToHex(hitCfg.color).toLowerCase();
  setHexBadge(val('hit-color-val'), hitCfg.color);
  halpha.value = Math.round((hitCfg.alpha||1)*100); setBadge(val('halpha-val'), `${halpha.value}%`);
  hthick.value = hitCfg.thickness; setBadge(val('hthick-val'), `${hthick.value}px`);
  hsize.value = hitCfg.size; setBadge(val('hsize-val'), `${hsize.value}px`);
  hdur.value = hitCfg.duration; setBadge(val('hdur-val'), `${hdur.value}`);
  houtline.checked = !!hitCfg.outline;
  houtth.value = hitCfg.outlineThickness; setBadge(val('houtth-val'), `${houtth.value}px`);
  houta.value = Math.round((hitCfg.outlineAlpha||0.8)*100); setBadge(val('houta-val'), `${houta.value}%`);
}
function pushHit(update){
  hitCfg = { ...hitCfg, ...update, color: update.color ? update.color : hitCfg.color };
  applyHitCfg(hitCfg);
  fetch(`https://${GetParentResourceName()}/updateHit`,{
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body: JSON.stringify(hitCfg)
  }).catch(()=>{});
}

/* ---------- Popup wiring ---------- */
function openPopup(current, enabled, cfg, hit, defaultTab) {
  if (cfg) { customCfg = cfg; applyCustom(cfg); fillCustomControls(cfg); }
  if (hit) { applyHitCfg(hit); }

  // force-clean previews and show the correct one immediately
  currentPreviewEl = null;
  hardShowPreview(current || 'modern');

  // live overlay selection
  showType(current || 'modern', { immediate:true });

  // default tab
  switchTab(defaultTab === 'hit' ? 'hit' : 'crosshair');

  popup.classList.remove('hidden');
}
function hidePopup() { popup.classList.add('hidden'); }
function requestClosePopup() {
  fetch(`https://${GetParentResourceName()}/closePopup`, {
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body: JSON.stringify({})
  }).finally(() => { hidePopup(); });
}

xClose.addEventListener('click', requestClosePopup);
popup.addEventListener('mousedown', (e) => { if (e.target === popup) requestClosePopup(); });
window.addEventListener('keydown', (e) => { if (e.key === 'Escape' && !popup.classList.contains('hidden')) requestClosePopup(); });

chips.forEach(chip => {
  chip.addEventListener('click', () => {
    const ctype = chip.dataset.type;
    fetch(`https://${GetParentResourceName()}/selectCrosshair`, {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify({ ctype })
    }).then(() => showType(ctype, { immediate:true }));
  });
});

hitStyleChips.forEach(ch => {
  ch.addEventListener('click', () => {
    const style = ch.dataset.hit;
    hitStyleChips.forEach(x => x.classList.toggle('active', x === ch));
    pushHit({ style });
  });
});
hitColorInput.addEventListener('input', () => pushHit({ color: hexToRgb(hitColorInput.value) }));
halpha.addEventListener('input', ()=> pushHit({ alpha: (+halpha.value)/100 }));
hthick.addEventListener('input', ()=> pushHit({ thickness: +hthick.value }));
hsize.addEventListener('input',  ()=> pushHit({ size: +hsize.value }));
hdur.addEventListener('input',   ()=> pushHit({ duration: +hdur.value }));
houtline.addEventListener('change', ()=> pushHit({ outline: !!houtline.checked }));
houtth.addEventListener('input', ()=> pushHit({ outlineThickness: +houtth.value }));
houta.addEventListener('input',  ()=> pushHit({ outlineAlpha: (+houta.value)/100 }));

/* ---------- Messages from client.lua ---------- */
window.addEventListener('message', (event) => {
  const d = event.data || {};
  if (d.action === 'openPopup') openPopup(d.current, d.enabled, d.cfg, d.hit, d.defaultTab);
  if (d.action === 'hidePopup') hidePopup();
  if (d.action === 'setCrosshair') showType(d.ctype, { immediate:true });
  if (d.action === 'setEnabled') setEnabled(!!d.enabled);
  if (d.action === 'setActive') setActive(!!d.active);
  if (d.action === 'playHitMarker' || d.action === 'flashCrosshair') playHitMarker();
  if (d.action === 'setCustom' && d.cfg) { customCfg = d.cfg; applyCustom(d.cfg); fillCustomControls(d.cfg); }
  if (d.action === 'dynamic' && typeof d.factor === 'number') {
    chCustom.style.setProperty('--dyn', Math.max(0, Math.min(1, d.factor)).toFixed(3));
  }
  if (d.action === 'setHitOptions' && d.cfg) { applyHitCfg(d.cfg); }
});
