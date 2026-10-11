/* ==========================================================
   VC LANDING — INITIALIZER  ·  V17
   Component: "Versatile Banner Theme Component CSS-light V17"
   ----------------------------------------------------------
   Owns the progressive-enhancement behaviors for the guest
   landing. All fail open: with this file absent the landing
   is fully visible and every trigger is still a working link.

   1. SCROLL REVEAL
      Adds <html class="vc-reveal-ready">, the only thing that
      turns on the hidden-then-animate state in common.scss.

   2. "HOW IT WORKS" MODAL
      Triggered by any [data-vc-howitworks] element or a link to
      #vc-why. With JS off, the trigger anchors to the indictment
      section, which is a reasonable answer to "how it works".

      HISTORY INTEGRATION
      Opening pushes a history entry so the phone/browser Back
      gesture CLOSES the modal instead of navigating away.
      Closing via × / ESC / backdrop unwinds that entry.

   CHANGED FROM V14  (V15 — "the walk")
      · 2b. THE WAY       one rail for the whole page; --vc-way-top /
           --vc-way-bottom place it, --vc-walk is how far the reader
           has come. Absent, CSS shows the rail whole and lit.

   CHANGED FROM V8  (V9 — additive, nothing removed)
      · 3. HEADER STATE   <html class="vc-at-top"> while the landing is
           scrolled to the top, so the header is transparent over the
           hero and frosted everywhere else. Without JS: always frosted.
      · 4. LAZY PLATES    .vc-fig background images are withheld until
           the figure is within 800px of the viewport (.vc-img-on).
      · 5. CANON READOUT  hover / tap a bar in the 66-book grid and a
           readout names the book and testament.
      · 6. JOIN BAR       phone-only sticky CTA (.vc-joinbar.is-on) shown
           between the hero buttons and the closing invitation.

   CHANGED FROM V7
      · Modal copy rewritten to the V8 narrative: the narrow road, the
        exegesis engine, the body, and Veritas for singles.
      · No structural change. Trigger selector, history integration,
        focus trap and the mobile sheet are all as proven in V6/V7.
   ========================================================== */
import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  document.documentElement.classList.add("vc-reveal-ready");

  /* ---------------------------------------------------------
     1. SCROLL REVEAL
     --------------------------------------------------------- */
  let io;
  let secIo;

  function scan() {
    const wrap = document.querySelector(".vc-landing-wrapper");
    if (!wrap) {
      return;
    }
    if (!io) {
      io = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              entry.target.classList.add("in");
              io.unobserve(entry.target);
            }
          });
        },
        { threshold: 0.1, rootMargin: "0px 0px -6% 0px" }
      );
    }
    wrap
      .querySelectorAll("[data-reveal]:not(.in)")
      .forEach((el) => io.observe(el));

    // V12 — the road thread: a section lights its own length of it
    if (!secIo) {
      secIo = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              entry.target.classList.add("vc-seen");
              secIo.unobserve(entry.target);
            }
          });
        },
        { threshold: 0, rootMargin: "0px 0px -12% 0px" }
      );
    }
    wrap
      .querySelectorAll(".vc-sec:not(.vc-seen)")
      .forEach((el) => secIo.observe(el));
  }

  /* ---------------------------------------------------------
     2b. THE WAY
     The rail runs from the foot of the hero to the closing gate, and
     --vc-walk is how much of it the reader has covered. Both are
     measured, never assumed, so the rail lands correctly whatever the
     content does. Absent this, CSS leaves the rail unlit and whole.
     --------------------------------------------------------- */
  let wayEl = null;
  let ticking = false;

  function measureWay(wrap) {
    wayEl = wrap.querySelector(".vc-way");
    if (!wayEl) {
      return;
    }
    const hero = wrap.querySelector(".vc-hero");
    const end = wrap.querySelector(".vc-arrive") || wrap.querySelector(".vc-final");
    const wrapTop = wrap.getBoundingClientRect().top;
    const top = hero ? hero.getBoundingClientRect().bottom - wrapTop : 0;
    const bottom = end
      ? wrap.offsetHeight - (end.getBoundingClientRect().top - wrapTop)
      : 0;
    wrap.style.setProperty("--vc-way-top", `${Math.round(top)}px`);
    wrap.style.setProperty("--vc-way-bottom", `${Math.round(bottom)}px`);
    walk();
  }

  function walk() {
    if (!wayEl || !wayEl.isConnected) {
      return;
    }
    const r = wayEl.getBoundingClientRect();
    if (!r.height) {
      return;
    }
    const here = window.innerHeight * 0.58;
    const p = Math.min(1, Math.max(0, (here - r.top) / r.height));
    wayEl.style.setProperty("--vc-walk", p.toFixed(4));
  }

  function onScroll() {
    if (ticking) {
      return;
    }
    ticking = true;
    requestAnimationFrame(() => {
      ticking = false;
      walk();
    });
  }
  window.addEventListener("scroll", onScroll, { passive: true });
  window.addEventListener(
    "resize",
    () => {
      const wrap = document.querySelector(".vc-landing-wrapper");
      if (wrap) {
        measureWay(wrap);
      }
    },
    { passive: true }
  );

  /* ---------------------------------------------------------
     3. HEADER STATE — transparent at the top, frosted once scrolled
     --------------------------------------------------------- */
  const root = document.documentElement;
  let onLanding = false;

  function syncTop() {
    root.classList.toggle("vc-at-top", onLanding && window.scrollY < 12);
  }
  window.addEventListener("scroll", syncTop, { passive: true });

  /* ---------------------------------------------------------
     4. LAZY PLATES
     --------------------------------------------------------- */
  let imgIo;

  function lazyPlates(wrap) {
    if (imgIo) {
      imgIo.disconnect();
    }
    imgIo = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("vc-img-on");
            imgIo.unobserve(entry.target);
          }
        });
      },
      { rootMargin: "800px 0px 800px 0px" }
    );
    wrap
      .querySelectorAll(".vc-fig:not(.vc-img-on)")
      .forEach((el) => imgIo.observe(el));
  }

  /* ---------------------------------------------------------
     5. CANON READOUT — 66 bars, 66 names
     --------------------------------------------------------- */
  const BOOKS = (
    "Genesis|Exodus|Leviticus|Numbers|Deuteronomy|Joshua|Judges|Ruth|" +
    "1 Samuel|2 Samuel|1 Kings|2 Kings|1 Chronicles|2 Chronicles|Ezra|" +
    "Nehemiah|Esther|Job|Psalms|Proverbs|Ecclesiastes|Song of Solomon|" +
    "Isaiah|Jeremiah|Lamentations|Ezekiel|Daniel|Hosea|Joel|Amos|Obadiah|" +
    "Jonah|Micah|Nahum|Habakkuk|Zephaniah|Haggai|Zechariah|Malachi|" +
    "Matthew|Mark|Luke|John|Acts|Romans|1 Corinthians|2 Corinthians|" +
    "Galatians|Ephesians|Philippians|Colossians|1 Thessalonians|" +
    "2 Thessalonians|1 Timothy|2 Timothy|Titus|Philemon|Hebrews|James|" +
    "1 Peter|2 Peter|1 John|2 John|3 John|Jude|Revelation"
  ).split("|");
  const CANON_REST = "Genesis to Revelation \u2014 hover or tap a book.";

  function canonReadout(wrap) {
    const bars = wrap.querySelector(".vc-canon-bars");
    if (!bars || bars.dataset.vcBound) {
      return;
    }
    const cells = Array.from(bars.children);
    if (cells.length !== BOOKS.length) {
      return; // markup changed — leave the grid as a plain graphic
    }
    bars.dataset.vcBound = "1";

    const read = document.createElement("p");
    read.className = "vc-canon-read";
    read.setAttribute("aria-live", "polite");
    read.textContent = CANON_REST;
    bars.after(read);

    function show(cell) {
      const i = cells.indexOf(cell);
      if (i < 0) {
        return;
      }
      cells.forEach((c) => c.classList.toggle("is-on", c === cell));
      const t = i < 39 ? "Old Testament" : "New Testament";
      read.textContent = `${BOOKS[i]} \u00b7 ${t} \u00b7 ${i + 1} of 66`;
      read.classList.add("is-on");
    }
    bars.addEventListener("pointerover", (e) => show(e.target));
    bars.addEventListener("click", (e) => show(e.target));
    bars.addEventListener("pointerleave", (e) => {
      if (e.pointerType === "mouse") {
        cells.forEach((c) => c.classList.remove("is-on"));
        read.textContent = CANON_REST;
        read.classList.remove("is-on");
      }
    });
  }

  /* ---------------------------------------------------------
     6. JOIN BAR — phone-only sticky CTA
     --------------------------------------------------------- */
  let barIo;

  function joinBar(wrap) {
    const bar = wrap.querySelector(".vc-joinbar");
    const heroCta = wrap.querySelector(".vc-hero .vc-cta-group");
    const final = wrap.querySelector(".vc-final");
    if (!bar || !heroCta || !final) {
      return;
    }
    if (barIo) {
      barIo.disconnect();
    }
    const seen = new Map([
      [heroCta, true],
      [final, false],
    ]);
    barIo = new IntersectionObserver((entries) => {
      entries.forEach((entry) => seen.set(entry.target, entry.isIntersecting));
      bar.classList.toggle("is-on", !seen.get(heroCta) && !seen.get(final));
    });
    barIo.observe(heroCta);
    barIo.observe(final);
  }

  /* ---------------------------------------------------------
     2. "HOW IT WORKS" MODAL
     --------------------------------------------------------- */
  const MODAL_ID = "vc-hiw-modal";

  // --- editable content -----------------------------------
  const EYEBROW = "How it works";
  const TITLE = "From first visit to fellowship.";
  const SUB =
    "No algorithm decides what you believe. A simple path onto the narrow road \u2014 into a community where Scripture speaks, believers sharpen one another, and single believers find alignment on the same foundation.";
  const CTA_LABEL = "Join the community \u2192";
  const CTA_HREF = "/signup";
  const REASSURE = "Here, the Word is the measure. Without exception.";

  const STEPS = [
    {
      title: "Join the community.",
      body: "Create your account and step into a fellowship of born-again, Bible-believing Christians \u2014 real believers, not an audience.",
    },
    {
      title: "Open the Word together.",
      body: "Book by book, verse by verse. Discussion anchored in the text, where \u201Cwhat does it say?\u201D always comes before \u201Cwhat do I think?\u201D",
    },
    {
      title: "Ask what no one answers clearly.",
      body: "The exegesis engine opens the passage instead of handing you an opinion with a verse stapled to it \u2014 context honored, measured against the whole 66-book canon, and genuine tensions held honestly.",
    },
    {
      title: "Grow, sharpened \u2014 and sent.",
      body: "Iron sharpens iron. Walk with believers who hold the same fixed standard while the world shifts, and be built up to carry the Good News outward.",
    },
    {
      title: "Single? Nobody here swipes.",
      body: "Veritas sits down with you and asks about what you wrote \u2014 your testimony, what you are looking for, where you are with God right now. Ten weighted dimensions, two-thirds of the weight on faith.",
    },
  ];
  // --------------------------------------------------------

  let modalEl = null;
  let lastFocus = null;
  let isOpen = false;

  function buildModal() {
    const existing = document.getElementById(MODAL_ID);
    if (existing) {
      modalEl = existing;
      return;
    }

    const stepsHtml = STEPS.map((s, i) => {
      const n = String(i + 1).padStart(2, "0");
      return (
        `<li class="vc-hiw-step"><span class="vc-hiw-n">${n}</span>` +
        `<div class="vc-hiw-body"><h3>${s.title}</h3><p>${s.body}</p></div></li>`
      );
    }).join("");

    const html =
      `<div class="vc-hiw-overlay" id="${MODAL_ID}" role="dialog" aria-modal="true" aria-labelledby="vc-hiw-title">` +
      `<div class="vc-hiw-dialog" role="document">` +
      `<button type="button" class="vc-hiw-close" aria-label="Close">\u00d7</button>` +
      `<span class="vc-hiw-eyebrow">${EYEBROW}</span>` +
      `<h2 class="vc-hiw-title" id="vc-hiw-title">${TITLE}</h2>` +
      `<p class="vc-hiw-sub">${SUB}</p>` +
      `<ol class="vc-hiw-steps">${stepsHtml}</ol>` +
      `<div class="vc-hiw-foot"><a class="vc-hiw-cta" href="${CTA_HREF}">${CTA_LABEL}</a>` +
      `<span class="vc-hiw-reassure">${REASSURE}</span></div>` +
      `</div></div>`;

    const holder = document.createElement("div");
    holder.innerHTML = html;
    modalEl = holder.firstElementChild;
    document.body.appendChild(modalEl);

    modalEl
      .querySelector(".vc-hiw-close")
      .addEventListener("click", closeModal);
    modalEl.addEventListener("click", (e) => {
      if (e.target === modalEl) {
        closeModal();
      }
    });
    modalEl.addEventListener("keydown", trapFocus);
  }

  // Visual close only — no history side effects.
  function hide() {
    if (!modalEl) {
      return;
    }
    isOpen = false;
    modalEl.classList.remove("is-open");
    document.documentElement.style.overflow = "";
    if (lastFocus && lastFocus.focus) {
      lastFocus.focus();
    }
  }

  function openModal(e) {
    if (e && e.preventDefault) {
      e.preventDefault();
    }
    if (isOpen) {
      return;
    }
    buildModal();
    lastFocus = document.activeElement;
    isOpen = true;
    modalEl.classList.add("is-open");
    document.documentElement.style.overflow = "hidden";
    try {
      history.pushState({ vcHiw: true }, "", location.href);
    } catch (_) {
      /* no-op */
    }
    const closeBtn = modalEl.querySelector(".vc-hiw-close");
    requestAnimationFrame(() => closeBtn && closeBtn.focus());
  }

  // User-initiated close (×, ESC, backdrop): unwind the pushed entry.
  function closeModal() {
    if (!isOpen) {
      return;
    }
    hide();
    if (history.state && history.state.vcHiw) {
      history.back();
    }
  }

  function trapFocus(e) {
    if (e.key !== "Tab" || !isOpen) {
      return;
    }
    const f = modalEl.querySelectorAll(
      'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])'
    );
    if (!f.length) {
      return;
    }
    const first = f[0];
    const last = f[f.length - 1];
    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault();
      last.focus();
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  }

  // Back / forward: if our modal is open, the pop means "close it".
  window.addEventListener("popstate", () => {
    if (isOpen) {
      hide();
    }
  });

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && isOpen) {
      closeModal();
    }
  });

  function bindTriggers() {
    document
      .querySelectorAll(
        '.vc-landing-wrapper [data-vc-howitworks], .vc-landing-wrapper a[href="#vc-why"]'
      )
      .forEach((t) => {
        if (t.dataset.vcHiwBound) {
          return;
        }
        t.dataset.vcHiwBound = "1";
        t.addEventListener("click", openModal);
      });
  }

  /* ---------------------------------------------------------
     Page lifecycle — runs on every SPA navigation.
     --------------------------------------------------------- */
  api.onPageChange(() => {
    requestAnimationFrame(() =>
      requestAnimationFrame(() => {
        scan();
        const wrap = document.querySelector(".vc-landing-wrapper");
        onLanding = !!wrap;
        syncTop();
        if (wrap) {
          buildModal();
          bindTriggers();
          lazyPlates(wrap);
          canonReadout(wrap);
          joinBar(wrap);
          measureWay(wrap);
          // the hero plate settles once its own art has decoded
          setTimeout(() => measureWay(wrap), 400);
        } else if (isOpen) {
          hide();
        }
      })
    );
  });
});
