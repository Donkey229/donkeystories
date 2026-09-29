// Språkbyte: SV / EN / TH. Texterna ligger här; index.html innehåller svenska som standard.
const TEXTS = {
  sv: {
    "vlog.title": "Vi två på resa.", "vlog.hint": "Svep för nästa klipp →", "vlog.follow": "Följ",
    "vlog.audio": "Donkey Music · originalljud",
    "vlog.r1.title": "Regn i Nyhavn", "vlog.r1.text": "Köpenhamn en grå dag – båtar, fasader och kaffe i handen. #danmark #köpenhamn",
    "vlog.r2.title": "Över havet", "vlog.r2.text": "Färjan mot nästa land. Sjögång, havsluft och en åsna vid relingen. #färja #roadtrip",
    "vlog.r3.title": "Nästa stopp: Norge", "vlog.r3.text": "Fjordar, fjäll och alldeles för lite sömn. Följ med! #norge #vlogg",
    "nav.vlog": "Vlogg", "nav.music": "Musik", "nav.emma": "Emma & Du", "nav.tools": "Verktyg",
    "cards.emma.title": "Vår egen app", "cards.emma.text": "Bilder, meddelanden och kalender – bara för oss två och de vi bjuder in.",
    "private": "Privat · kräver inloggning",
    "tools.eyebrow": "Donkey Lab", "tools.title": "Verktygen bakom allt.",
    "tools.panel.text": "Tillägg till VEGAS Pro: färg, LUT:ar, klipp och projekt i en panel.",
    "tools.cubase.text": "AI-panel som skapar MIDI, stems och mallar som öppnas direkt i Cubase.",
    "tools.grading.tag": "Ljud & bild", "tools.grading.text": "Färggradering av S-Log-material – och snart gradering som tjänst.",
    "download.soon": "Nedladdning kommer snart", "cta.eyebrow": "Business",
    "hero.title": "Resor, musik och allt vi skapar.",
    "hero.lead": "Vi är Donkey och Emma. Här samlar vi våra vloggar, Donkey-musiken och verktygen vi bygger – allt på ett ställe.",
    "hero.cta": "Utforska",
    "cards.eyebrow": "Upptäck", "cards.title": "Tre världar, en åsna.",
    "cards.vlog.title": "Vi två på resa", "cards.vlog.text": "Danmark, Norge, Sverige och allt däremellan.",
    "cards.music.title": "Donkey Music", "cards.music.text": "Musikvideor och låtar gjorda från grunden.",
    "soon.short": "snart", "nav.label": "Meny", "logo.alt": "Donkey – logga",
    "soon": "Kommer snart",
    "about.eyebrow": "Om oss", "about.title": "Två personer, en kamera.",
    "about.p1": "Vi filmar det vi upplever – färjor över havet, regniga nätter i Köpenhamn och solnedgångar vid sjön.",
    "about.p2": "Donkey gör musiken och bygger verktygen. Emma ser till att kameran pekar åt rätt håll (för det mesta).",
    "video.eyebrow": "Senaste videon", "video.title": "Nytt avsnitt snart.",
    "video.text": "Här visas det senaste avsnittet från YouTube.",
    "cta.title": "Följ med på resan.", "cta.text": "Samarbeten, varumärke och tjänster inom ljud och bild – snart här.",
  },
  en: {
    "vlog.title": "The two of us, on the road.", "vlog.hint": "Swipe for the next clip →", "vlog.follow": "Follow",
    "vlog.audio": "Donkey Music · original audio",
    "vlog.r1.title": "Rain in Nyhavn", "vlog.r1.text": "Copenhagen on a grey day – boats, facades and a coffee in hand. #denmark #copenhagen",
    "vlog.r2.title": "Across the sea", "vlog.r2.text": "The ferry to the next country. Rolling waves, sea air and a donkey at the rail. #ferry #roadtrip",
    "vlog.r3.title": "Next stop: Norway", "vlog.r3.text": "Fjords, mountains and far too little sleep. Come along! #norway #vlog",
    "nav.vlog": "Vlog", "nav.music": "Music", "nav.emma": "Emma & You", "nav.tools": "Tools",
    "cards.emma.title": "Our own app", "cards.emma.text": "Photos, messages and a shared calendar – just for the two of us and the people we invite.",
    "private": "Private · sign-in required",
    "tools.eyebrow": "Donkey Lab", "tools.title": "The tools behind it all.",
    "tools.panel.text": "A VEGAS Pro extension: colour, LUTs, cuts and projects in one panel.",
    "tools.cubase.text": "An AI panel that creates MIDI, stems and templates that open straight in Cubase.",
    "tools.grading.tag": "Sound & image", "tools.grading.text": "Colour grading for S-Log footage – and soon grading as a service.",
    "download.soon": "Download coming soon", "cta.eyebrow": "Business",
    "hero.title": "Travel, music and everything we make.",
    "hero.lead": "We're Donkey and Emma. This is where we gather our vlogs, the Donkey music and the tools we build – all in one place.",
    "hero.cta": "Explore",
    "cards.eyebrow": "Discover", "cards.title": "Three worlds, one donkey.",
    "cards.vlog.title": "The two of us, on the road", "cards.vlog.text": "Denmark, Norway, Sweden and everything in between.",
    "cards.music.title": "Donkey Music", "cards.music.text": "Music videos and songs made from scratch.",
    "soon.short": "soon", "nav.label": "Menu", "logo.alt": "Donkey – logo",
    "soon": "Coming soon",
    "about.eyebrow": "About us", "about.title": "Two people, one camera.",
    "about.p1": "We film what we live – ferries across the sea, rainy nights in Copenhagen and sunsets by the lake.",
    "about.p2": "Donkey makes the music and builds the tools. Emma keeps the camera pointed the right way (most of the time).",
    "video.eyebrow": "Latest video", "video.title": "New episode soon.",
    "video.text": "The latest YouTube episode will appear here.",
    "cta.title": "Come along for the ride.", "cta.text": "Collaborations, brand work and sound & image services – coming soon.",
  },
  th: {
    "vlog.title": "เราสองคนออกเดินทาง", "vlog.hint": "ปัดเพื่อดูคลิปถัดไป →", "vlog.follow": "ติดตาม",
    "vlog.audio": "Donkey Music · เสียงต้นฉบับ",
    "vlog.r1.title": "ฝนตกที่นีฮาวน์", "vlog.r1.text": "โคเปนเฮเกนในวันฟ้าครึ้ม – เรือ ตึกหลากสี และกาแฟในมือ #เดนมาร์ก #โคเปนเฮเกน",
    "vlog.r2.title": "ข้ามทะเล", "vlog.r2.text": "เรือเฟอร์รี่สู่ประเทศถัดไป คลื่นลม อากาศทะเล และลาหนึ่งตัวที่ราวเรือ #เฟอร์รี่ #roadtrip",
    "vlog.r3.title": "จุดหมายถัดไป: นอร์เวย์", "vlog.r3.text": "ฟยอร์ด ภูเขา และการนอนที่น้อยเกินไป มาเที่ยวด้วยกัน! #นอร์เวย์ #วล็อก",
    "nav.vlog": "วล็อก", "nav.music": "เพลง", "nav.emma": "เอ็มม่ากับคุณ", "nav.tools": "เครื่องมือ",
    "cards.emma.title": "แอปของเราเอง", "cards.emma.text": "รูปภาพ ข้อความ และปฏิทิน – สำหรับเราสองคนและคนที่เราเชิญเท่านั้น",
    "private": "ส่วนตัว · ต้องเข้าสู่ระบบ",
    "tools.eyebrow": "Donkey Lab", "tools.title": "เครื่องมือเบื้องหลังทุกอย่าง",
    "tools.panel.text": "ส่วนเสริมสำหรับ VEGAS Pro: สี LUT การตัดต่อ และโปรเจกต์ ในแผงเดียว",
    "tools.cubase.text": "แผง AI ที่สร้าง MIDI, สเต็ม และเทมเพลตที่เปิดใน Cubase ได้ทันที",
    "tools.grading.tag": "เสียงและภาพ", "tools.grading.text": "เกรดสีฟุตเทจ S-Log – และเร็ว ๆ นี้บริการเกรดสี",
    "download.soon": "ดาวน์โหลดเร็ว ๆ นี้", "cta.eyebrow": "ธุรกิจ",
    "hero.title": "การเดินทาง ดนตรี และทุกสิ่งที่เราสร้าง",
    "hero.lead": "เราคือดองกี้และเอ็มม่า ที่นี่คือที่รวมวล็อกของเรา เพลงของดองกี้ และเครื่องมือที่เราสร้างขึ้น – ครบในที่เดียว",
    "hero.cta": "สำรวจ",
    "cards.eyebrow": "ค้นพบ", "cards.title": "สามโลก หนึ่งลา",
    "cards.vlog.title": "เราสองคนออกเดินทาง", "cards.vlog.text": "เดนมาร์ก นอร์เวย์ สวีเดน และทุกที่ระหว่างทาง",
    "cards.music.title": "Donkey Music", "cards.music.text": "มิวสิกวิดีโอและเพลงที่ทำขึ้นเองตั้งแต่ต้น",
    "soon.short": "เร็ว ๆ นี้", "nav.label": "เมนู", "logo.alt": "โลโก้ Donkey",
    "soon": "เร็ว ๆ นี้",
    "about.eyebrow": "เกี่ยวกับเรา", "about.title": "สองคน หนึ่งกล้อง",
    "about.p1": "เราถ่ายทุกสิ่งที่เราได้พบเจอ – เรือข้ามทะเล คืนฝนพรำในโคเปนเฮเกน และพระอาทิตย์ตกริมทะเลสาบ",
    "about.p2": "ดองกี้ทำเพลงและสร้างเครื่องมือ ส่วนเอ็มม่าคอยดูให้กล้องหันไปถูกทาง (เกือบทุกครั้ง)",
    "video.eyebrow": "วิดีโอล่าสุด", "video.title": "ตอนใหม่เร็ว ๆ นี้",
    "video.text": "ตอนล่าสุดจาก YouTube จะแสดงที่นี่",
    "cta.title": "มาร่วมเดินทางไปกับเรา", "cta.text": "งานร่วมมือ แบรนด์ และบริการด้านเสียงและภาพ – เร็ว ๆ นี้",
  },
};

function pickStartLang() {
  try {
    const saved = localStorage.getItem("lang");
    if (saved && TEXTS[saved]) return saved;
  } catch (e) {}
  const nav = (navigator.languages || [navigator.language || "en"]).map(l => l.toLowerCase());
  for (const l of nav) {
    if (l.startsWith("th")) return "th";
    if (l.startsWith("sv")) return "sv";
  }
  return "en";
}

function setLang(lang) {
  const t = TEXTS[lang];
  document.documentElement.lang = lang;
  document.querySelectorAll("[data-i18n]").forEach(el => {
    const v = t[el.dataset.i18n];
    if (v) el.textContent = v;
  });
  // attribut som alt och aria-label: data-i18n-attr="alt:logo.alt"
  document.querySelectorAll("[data-i18n-attr]").forEach(el => {
    const [attr, key] = el.dataset.i18nAttr.split(":");
    if (t[key]) el.setAttribute(attr, t[key]);
  });
  document.querySelectorAll(".lang button").forEach(b => {
    b.setAttribute("aria-pressed", String(b.dataset.lang === lang));
  });
  try { localStorage.setItem("lang", lang); } catch (e) {}
}

document.querySelectorAll(".lang button").forEach(b => {
  b.addEventListener("click", () => setLang(b.dataset.lang));
});
setLang(pickStartLang());
