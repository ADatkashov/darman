'use strict';
const API = '/api/v1';
const state = { token: null, refresh: null, me: null, perms: [] };
const $ = (s, r = document) => r.querySelector(s);
const esc = (v) => String(v ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const money = (n) => new Intl.NumberFormat('ru-RU').format(n) + ' ₸';
const dt = (s) => (s ? new Date(s).toLocaleString('ru-RU') : '—');

async function api(path, opts = {}, retry = true) {
  const headers = { Accept: 'application/json', ...(opts.body && !(opts.body instanceof FormData) ? { 'Content-Type': 'application/json' } : {}) };
  if (state.token) headers.Authorization = 'Bearer ' + state.token;
  const res = await fetch(API + path, { ...opts, headers, body: opts.body && !(opts.body instanceof FormData) ? JSON.stringify(opts.body) : opts.body });
  if (res.status === 401 && retry && state.refresh && !path.startsWith('/auth/')) {
    if (await refresh()) return api(path, opts, false);
    signOut();
    throw new Error('Сессия истекла');
  }
  if (opts.raw) return res;
  const text = await res.text();
  const data = text ? JSON.parse(text) : null;
  if (!res.ok) {
    const fields = (data?.fieldErrors || []).map((f) => `${f.field}: ${f.message}`).join('; ');
    throw new Error((data?.code ? data.code + (fields ? ' — ' + fields : '') : 'HTTP ' + res.status));
  }
  return data;
}

async function refresh() {
  try {
    const r = await fetch(API + '/auth/refresh', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ refreshToken: state.refresh }) });
    if (!r.ok) return false;
    const d = await r.json();
    state.token = d.accessToken; state.refresh = d.refreshToken;
    sessionStorage.setItem('dm_refresh', state.refresh);
    return true;
  } catch { return false; }
}

function signOut() {
  if (state.refresh) fetch(API + '/auth/logout', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ refreshToken: state.refresh }) }).catch(() => {});
  state.token = state.refresh = null; sessionStorage.removeItem('dm_refresh');
  $('#login').hidden = false; $('#app').hidden = true; $('#logout').hidden = true; $('#who').textContent = '';
}

async function start(tokens) {
  state.token = tokens.accessToken; state.refresh = tokens.refreshToken;
  sessionStorage.setItem('dm_refresh', state.refresh);
  const me = await api('/admin/me');
  state.me = me; state.perms = me.permissions;
  $('#who').textContent = (tokens.user?.fullName || '') + ' · ' + me.role;
  $('#login').hidden = true; $('#app').hidden = false; $('#logout').hidden = false;
  buildTabs();
}

const TABS = [
  ['orders', 'Заказы', 'ORDERS_PROCESS', ordersView],
  ['rx', 'Рецепты', 'PRESCRIPTION_REVIEW', rxView],
  ['offers', 'Предложения и остатки', 'INVENTORY_WRITE', offersView],
  ['products', 'Товары', 'CATALOG_WRITE', productsView],
  ['promos', 'Промо', 'PROMOTIONS_WRITE', promosView],
  ['audit', 'Аудит', 'AUDIT_READ', auditView],
  ['staff', 'Сотрудники', 'STAFF_MANAGE', staffView],
];

function buildTabs() {
  const nav = $('#tabs'); nav.innerHTML = '';
  const allowed = TABS.filter((t) => state.perms.includes(t[2]));
  allowed.forEach(([id, label, , fn], i) => {
    const b = document.createElement('button');
    b.textContent = label; b.setAttribute('role', 'tab'); b.dataset.id = id;
    b.onclick = () => { nav.querySelectorAll('button').forEach((x) => x.setAttribute('aria-selected', x === b)); render(fn); };
    nav.appendChild(b);
    if (i === 0) b.click();
  });
}

async function render(fn) {
  const v = $('#view'); v.innerHTML = '<p class="muted">Загрузка…</p>';
  try { await fn(v); } catch (e) { v.innerHTML = `<p class="error" role="alert">${esc(e.message)}</p>`; }
}

function pager(page, data, go) {
  return `<div class="pager"><button class="sec" ${page <= 0 ? 'disabled' : ''} data-p="${page - 1}">←</button><span>${page + 1} / ${Math.max(data.totalPages, 1)} · всего ${data.totalItems}</span><button class="sec" ${data.hasNext ? '' : 'disabled'} data-p="${page + 1}">→</button></div>`;
}
function bindPager(v, go) { v.querySelectorAll('.pager button').forEach((b) => (b.onclick = () => go(+b.dataset.p))); }

// ───── orders ─────
const NEXT = { PLACED: 'CONFIRMED', CONFIRMED: 'PREPARING', PREPARING: null, READY_FOR_PICKUP: 'DELIVERED', IN_TRANSIT: 'DELIVERED' };
async function ordersView(v, page = 0, q = '', status = '') {
  const d = await api(`/admin/orders?page=${page}&size=15&q=${encodeURIComponent(q)}${status ? '&status=' + status : ''}`);
  v.innerHTML = `<div class="row"><label>Поиск (номер/телефон)<input id="q" value="${esc(q)}"></label>
    <label>Статус<select id="st"><option value="">Все</option>${['PLACED', 'CONFIRMED', 'PREPARING', 'READY_FOR_PICKUP', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED'].map((s) => `<option ${s === status ? 'selected' : ''}>${s}</option>`).join('')}</select></label><button id="go">Найти</button></div>
    <table><tr><th>Номер</th><th>Статус</th><th>Тип</th><th>Сумма</th><th>Создан</th><th></th></tr>
    ${d.items.map((o) => `<tr><td>${esc(o.number)}</td><td><span class="pill ${o.status === 'CANCELLED' ? 'bad' : ''}">${esc(o.status)}</span></td><td>${esc(o.fulfillment)}</td><td>${money(o.total)}</td><td>${dt(o.createdAt)}</td><td><button class="sec" data-open="${esc(o.id)}">Открыть</button></td></tr>`).join('')}</table>${pager(page, d)}`;
  $('#go', v).onclick = () => ordersView(v, 0, $('#q', v).value, $('#st', v).value);
  bindPager(v, (p) => ordersView(v, p, q, status));
  v.querySelectorAll('[data-open]').forEach((b) => (b.onclick = () => orderDialog(b.dataset.open, () => ordersView(v, page, q, status))));
}

async function orderDialog(id, done) {
  const o = await api('/admin/orders/' + id);
  const dlg = document.createElement('dialog');
  const next = o.fulfillment === 'PICKUP' && o.status === 'PREPARING' ? 'READY_FOR_PICKUP' : o.fulfillment === 'DELIVERY' && o.status === 'PREPARING' ? 'IN_TRANSIT' : NEXT[o.status];
  const canCancel = ['PLACED', 'CONFIRMED', 'PREPARING', 'READY_FOR_PICKUP'].includes(o.status);
  dlg.innerHTML = `<h2>Заказ ${esc(o.number)}</h2><p><span class="pill">${esc(o.status)}</span> ${esc(o.fulfillment)} · оплата: ${esc(o.paymentMethod)} / ${esc(o.paymentStatus)}${o.paymentIsDemo ? ' (ДЕМО)' : ''}</p>
    <p>${esc(o.contactName)}, ${esc(o.contactPhone)}<br>${esc(o.deliveryAddress || 'Самовывоз: ' + (o.branchName || ''))}</p>
    <table>${o.items.map((i) => `<tr><td>${esc(i.productName)}${i.rxRequired ? ' <span class="pill warn">Rx</span>' : ''}</td><td>${i.quantity} × ${money(i.unitPrice)}</td></tr>`).join('')}<tr><th>Итого</th><th>${money(o.total)}</th></tr></table>
    ${o.fulfillment === 'DELIVERY' ? `<h3>Курьер</h3><div class="row"><label>Имя<input id="cn" value="${esc(o.courier?.name || '')}"></label><label>Телефон<input id="cp" value="${esc(o.courier?.phone || '')}"></label><button id="cs" class="sec">Назначить</button></div>` : ''}
    <div class="actions">${next ? `<button id="adv">→ ${next}</button>` : ''}${canCancel ? '<button id="cx" class="danger">Отменить</button>' : ''}<button class="sec" id="cl">Закрыть</button></div><p id="err" class="error"></p>`;
  document.body.appendChild(dlg); dlg.showModal();
  const close = () => { dlg.close(); dlg.remove(); done(); };
  const act = (fn) => async () => { try { await fn(); close(); } catch (e) { $('#err', dlg).textContent = e.message; } };
  $('#cl', dlg).onclick = close;
  if (next) $('#adv', dlg).onclick = act(() => api(`/admin/orders/${id}/status`, { method: 'POST', body: { status: next } }));
  if (canCancel) $('#cx', dlg).onclick = act(() => api(`/admin/orders/${id}/status`, { method: 'POST', body: { status: 'CANCELLED', comment: 'Отменено сотрудником' } }));
  if (o.fulfillment === 'DELIVERY') $('#cs', dlg).onclick = act(() => api(`/admin/orders/${id}/courier`, { method: 'PUT', body: { name: $('#cn', dlg).value, phone: $('#cp', dlg).value } }));
}

// ───── prescriptions ─────
async function rxView(v, page = 0, status = 'SUBMITTED,UNDER_REVIEW') {
  const d = await api(`/admin/prescriptions?page=${page}&size=15&` + status.split(',').map((s) => 'status=' + s).join('&'));
  v.innerHTML = `<p class="muted">Доступ к файлам рецептов фиксируется в журнале аудита. Одобрять может только пользователь с правом PRESCRIPTION_REVIEW (лицензированный фармацевт).</p>
    <div class="row"><label>Фильтр<select id="f"><option value="SUBMITTED,UNDER_REVIEW">В очереди</option><option value="APPROVED">Одобренные</option><option value="REJECTED">Отклонённые</option></select></label></div>
    <table><tr><th>Пациент</th><th>Статус</th><th>Файлов</th><th>Отправлен</th><th></th></tr>
    ${d.items.map((r) => `<tr><td>${esc(r.userFullName || '—')}</td><td><span class="pill">${esc(r.prescription.status)}</span></td><td>${r.prescription.files.length}</td><td>${dt(r.prescription.submittedAt)}</td><td><button class="sec" data-open="${esc(r.prescription.id)}">Открыть</button></td></tr>`).join('')}</table>${pager(page, d)}`;
  $('#f', v).value = status; $('#f', v).onchange = () => rxView(v, 0, $('#f', v).value);
  bindPager(v, (p) => rxView(v, p, status));
  v.querySelectorAll('[data-open]').forEach((b) => (b.onclick = () => rxDialog(b.dataset.open, () => rxView(v, page, status))));
}

async function rxDialog(id, done) {
  const p = await api('/admin/prescriptions/' + id);
  const dlg = document.createElement('dialog');
  dlg.innerHTML = `<h2>Рецепт</h2><p><span class="pill">${esc(p.status)}</span> ${p.demoReview ? '<span class="pill warn">DEMO</span>' : ''}</p>
    <div class="actions">${p.files.map((f) => `<button class="sec" data-f="${esc(f.id)}">${esc(f.originalName)}</button>`).join('')}</div>
    <h3>История</h3><ul>${p.events.map((e) => `<li>${dt(e.createdAt)} — ${esc(e.type)} ${esc(e.comment || '')}</li>`).join('')}</ul>
    <label>Комментарий / причина отказа<textarea id="c" rows="2"></textarea></label>
    <div class="actions">${p.status === 'SUBMITTED' ? '<button id="st">Начать проверку</button>' : ''}${p.status === 'UNDER_REVIEW' ? '<button id="ok">Одобрить</button><button id="no" class="danger">Отклонить</button>' : ''}<button class="sec" id="cl">Закрыть</button></div><p id="err" class="error"></p>`;
  document.body.appendChild(dlg); dlg.showModal();
  const close = () => { dlg.close(); dlg.remove(); done(); };
  const act = (fn) => async () => { try { await fn(); close(); } catch (e) { $('#err', dlg).textContent = e.message; } };
  $('#cl', dlg).onclick = close;
  dlg.querySelectorAll('[data-f]').forEach((b) => (b.onclick = async () => {
    const r = await api(`/prescriptions/${id}/files/${b.dataset.f}`, { raw: true });
    if (!r.ok) { $('#err', dlg).textContent = 'HTTP ' + r.status; return; }
    window.open(URL.createObjectURL(await r.blob()), '_blank', 'noopener');
  }));
  if ($('#st', dlg)) $('#st', dlg).onclick = act(() => api(`/admin/prescriptions/${id}/start-review`, { method: 'POST' }));
  if ($('#ok', dlg)) $('#ok', dlg).onclick = act(() => api(`/admin/prescriptions/${id}/approve`, { method: 'POST', body: { comment: $('#c', dlg).value } }));
  if ($('#no', dlg)) $('#no', dlg).onclick = act(() => api(`/admin/prescriptions/${id}/reject`, { method: 'POST', body: { reason: $('#c', dlg).value } }));
}

// ───── offers & stock ─────
async function offersView(v, page = 0) {
  const d = await api(`/admin/offers?page=${page}&size=20`);
  v.innerHTML = `<table><tr><th>Товар</th><th>Аптека / филиал</th><th>Цена</th><th>Остаток</th><th>Активно</th><th></th></tr>
    ${d.items.map((o) => `<tr><td>${esc(o.productName)}</td><td>${esc(o.pharmacyName)} · ${esc(o.branchName)}</td><td>${money(o.price)}</td><td><input type="number" min="0" value="${o.quantity}" data-q="${esc(o.id)}" style="width:90px"></td><td>${o.active ? 'да' : 'нет'}</td>
    <td class="actions"><button data-s="${esc(o.id)}">Сохранить</button><button class="sec" data-t="${esc(o.id)}" data-a="${o.active ? 'disable' : 'enable'}">${o.active ? 'Отключить' : 'Включить'}</button></td></tr>`).join('')}</table>${pager(page, d)}<p id="err" class="error"></p>`;
  bindPager(v, (p) => offersView(v, p));
  v.querySelectorAll('[data-s]').forEach((b) => (b.onclick = async () => { try { await api(`/admin/offers/${b.dataset.s}/stock`, { method: 'PATCH', body: { quantity: +v.querySelector(`[data-q="${b.dataset.s}"]`).value } }); b.textContent = 'Готово'; } catch (e) { $('#err', v).textContent = e.message; } }));
  v.querySelectorAll('[data-t]').forEach((b) => (b.onclick = async () => { await api(`/admin/offers/${b.dataset.t}/${b.dataset.a}`, { method: 'POST' }); offersView(v, page); }));
}

// ───── products ─────
async function productsView(v, page = 0, q = '') {
  const d = await api(`/admin/products?page=${page}&size=20&q=${encodeURIComponent(q)}`);
  v.innerHTML = `<div class="row"><label>Поиск<input id="q" value="${esc(q)}"></label><button id="go">Найти</button></div>
    <table><tr><th>Название</th><th>Рецепт</th><th>Активен</th><th>Демо</th><th></th></tr>
    ${d.items.map((p) => `<tr><td>${esc(p.name)}</td><td>${p.rxRequired ? '<span class="pill warn">Rx</span>' : 'OTC'}</td><td>${p.active ? 'да' : 'нет'}</td><td>${p.demo ? 'да' : ''}</td><td>${p.active ? `<button class="sec" data-d="${esc(p.id)}">Деактивировать</button>` : ''}</td></tr>`).join('')}</table>${pager(page, d)}<p id="err" class="error"></p>`;
  $('#go', v).onclick = () => productsView(v, 0, $('#q', v).value);
  bindPager(v, (p) => productsView(v, p, q));
  v.querySelectorAll('[data-d]').forEach((b) => (b.onclick = async () => { try { await api('/admin/products/' + b.dataset.d, { method: 'DELETE' }); productsView(v, page, q); } catch (e) { $('#err', v).textContent = e.message; } }));
}

// ───── promos ─────
async function promosView(v) {
  const list = await api('/admin/promotions');
  v.innerHTML = `<table><tr><th>Тип</th><th>Код</th><th>Заголовок</th><th>%</th><th>Активна</th><th></th></tr>
    ${list.map((p) => `<tr><td>${esc(p.kind)}</td><td>${esc(p.code || '')}</td><td>${esc(p.titleRu)}</td><td>${p.discountPercent ?? ''}</td><td>${p.active ? 'да' : 'нет'}</td><td>${p.active ? `<button class="sec" data-d="${esc(p.id)}">Выключить</button>` : ''}</td></tr>`).join('')}</table>
    <h3>Новый промокод</h3><form id="f" class="row"><label>Код<input name="code" required pattern="[A-Za-z0-9_-]+"></label><label>Скидка %<input name="pct" type="number" min="1" max="90" required></label><label>Мин. сумма<input name="min" type="number" min="0"></label><label>Заголовок (ru)<input name="title" required></label><button>Создать</button></form><p id="err" class="error"></p>`;
  v.querySelectorAll('[data-d]').forEach((b) => (b.onclick = async () => { await api('/admin/promotions/' + b.dataset.d, { method: 'DELETE' }); promosView(v); }));
  $('#f', v).onsubmit = async (e) => {
    e.preventDefault(); const f = new FormData(e.target);
    try { await api('/admin/promotions', { method: 'POST', body: { kind: 'PROMO_CODE', code: f.get('code'), titleRu: f.get('title'), titleKk: f.get('title'), titleEn: f.get('title'), discountPercent: +f.get('pct'), minOrderAmount: f.get('min') ? +f.get('min') : null } }); promosView(v); } catch (er) { $('#err', v).textContent = er.message; }
  };
}

// ───── audit & staff ─────
async function auditView(v, page = 0) {
  const d = await api(`/admin/audit?page=${page}&size=40`);
  v.innerHTML = `<table><tr><th>Время</th><th>Действие</th><th>Роль</th><th>Объект</th><th>Детали</th></tr>${d.items.map((a) => `<tr><td>${dt(a.createdAt)}</td><td>${esc(a.action)}</td><td>${esc(a.actorRole || '')}</td><td>${esc(a.entityType || '')} ${esc((a.entityId || '').slice(0, 12))}</td><td>${esc(a.details || '')}</td></tr>`).join('')}</table>${pager(page, d)}`;
  bindPager(v, (p) => auditView(v, p));
}

async function staffView(v) {
  const [d, roles] = await Promise.all([api('/admin/staff'), api('/admin/roles')]);
  const opts = (cur) => roles.filter((r) => r.role !== 'CUSTOMER').map((r) => `<option ${r.role === cur ? 'selected' : ''}>${esc(r.role)}</option>`).join('');
  v.innerHTML = `<table><tr><th>Имя</th><th>Телефон</th><th>Роль</th><th>Статус</th><th></th></tr>${d.items.map((u) => `<tr><td>${esc(u.fullName || '')}</td><td>${esc(u.phone)}</td><td><select data-r="${esc(u.id)}">${opts(u.role)}</select></td><td>${esc(u.status)}</td><td class="actions"><button data-save="${esc(u.id)}">Сохранить</button><button class="sec" data-tog="${esc(u.id)}" data-st="${u.status === 'ACTIVE' ? 'DISABLED' : 'ACTIVE'}">${u.status === 'ACTIVE' ? 'Отключить' : 'Включить'}</button></td></tr>`).join('')}</table>
    <h3>Матрица прав</h3><table><tr><th>Роль</th><th>Права</th></tr>${roles.map((r) => `<tr><td>${esc(r.role)}</td><td>${esc(r.permissions || '—')}</td></tr>`).join('')}</table>
    <h3>Новый сотрудник</h3><form id="f" class="row"><label>Телефон<input name="phone" required></label><label>Имя<input name="name"></label><label>Пароль (≥12)<input name="pw" type="password" minlength="12" required></label><label>Роль<select name="role">${opts('PHARMACIST')}</select></label><button>Создать</button></form><p id="err" class="error"></p>`;
  const err = (e) => ($('#err', v).textContent = e.message);
  v.querySelectorAll('[data-save]').forEach((b) => (b.onclick = () => api('/admin/staff/' + b.dataset.save, { method: 'PATCH', body: { role: v.querySelector(`[data-r="${b.dataset.save}"]`).value } }).then(() => staffView(v), err)));
  v.querySelectorAll('[data-tog]').forEach((b) => (b.onclick = () => api('/admin/staff/' + b.dataset.tog, { method: 'PATCH', body: { status: b.dataset.st } }).then(() => staffView(v), err)));
  $('#f', v).onsubmit = (e) => { e.preventDefault(); const f = new FormData(e.target); api('/admin/staff', { method: 'POST', body: { phone: f.get('phone'), fullName: f.get('name'), password: f.get('pw'), role: f.get('role') } }).then(() => staffView(v), err); };
}

// ───── bootstrap ─────
$('#login-form').onsubmit = async (e) => {
  e.preventDefault(); const f = new FormData(e.target); $('#login-error').textContent = '';
  try {
    const r = await fetch(API + '/auth/login', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ phone: f.get('phone'), password: f.get('password') }) });
    const d = await r.json();
    if (!r.ok) throw new Error(d.code || 'HTTP ' + r.status);
    if (d.user.role === 'CUSTOMER') throw new Error('Нет доступа: это панель сотрудников');
    await start(d);
  } catch (er) { $('#login-error').textContent = er.message; }
};
$('#logout').onclick = signOut;
fetch(API + '/config').then((r) => r.json()).then((c) => { $('#demo-banner').hidden = !c.demoMode; }).catch(() => {});
