/* =========================================
   PREMIUM PORTFOLIO JAVASCRIPT
========================================= */


/* MOBILE NAVIGATION */

const menuToggle = document.querySelector("#menu-toggle");
const navLinks = document.querySelector("#nav-links");

if (menuToggle && navLinks) {
  menuToggle.addEventListener("click", () => {
    navLinks.classList.toggle("show");
  });

  const navigationLinks = navLinks.querySelectorAll("a");

  navigationLinks.forEach((link) => {
    link.addEventListener("click", () => {
      navLinks.classList.remove("show");
    });
  });
}


/* TYPING ANIMATION */

const typingText = document.querySelector("#typing-text");

const roles = [
  "AI/ML Student",
  "C++ Developer",
  "Python Developer",
  "Web Developer"
];

let roleIndex = 0;
let characterIndex = 0;
let deleting = false;

function typeRole() {
  if (!typingText) return;

  const currentRole = roles[roleIndex];

  if (!deleting) {
    characterIndex++;

    typingText.textContent = currentRole.substring(
      0,
      characterIndex
    );
  } else {
    characterIndex--;

    typingText.textContent = currentRole.substring(
      0,
      characterIndex
    );
  }

  let speed = deleting ? 45 : 85;

  if (!deleting && characterIndex === currentRole.length) {
    speed = 1800;
    deleting = true;
  }

  if (deleting && characterIndex === 0) {
    deleting = false;
    roleIndex = (roleIndex + 1) % roles.length;
    speed = 500;
  }

  setTimeout(typeRole, speed);
}

typeRole();


/* PROJECT FILTER */

const filterButtons =
  document.querySelectorAll(".filter-button");

const projectCards =
  document.querySelectorAll(".project-card");

filterButtons.forEach((button) => {
  button.addEventListener("click", () => {
    const selectedFilter =
      button.dataset.filter;

    filterButtons.forEach((item) => {
      item.classList.remove("active");
    });

    button.classList.add("active");

    projectCards.forEach((card) => {
      const category =
        card.dataset.category;

      const shouldShow =
        selectedFilter === "all" ||
        selectedFilter === category;

      card.classList.toggle(
        "hidden",
        !shouldShow
      );
    });
  });
});


/* SCROLL REVEAL */

const revealElements =
  document.querySelectorAll(".reveal");

const revealObserver =
  new IntersectionObserver(
    (entries, observer) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("visible");

          observer.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.12
    }
  );

revealElements.forEach((element) => {
  revealObserver.observe(element);
});


/* CURSOR GLOW */

const cursorGlow =
  document.querySelector(".cursor-glow");

if (
  cursorGlow &&
  window.matchMedia("(pointer: fine)").matches
) {
  window.addEventListener("mousemove", (event) => {
    cursorGlow.style.left =
      `${event.clientX}px`;

    cursorGlow.style.top =
      `${event.clientY}px`;
  });
}


/* HEADER SCROLL EFFECT */

const header =
  document.querySelector(".site-header");

window.addEventListener(
  "scroll",
  () => {
    const currentScroll =
      window.scrollY;

    if (currentScroll > 30) {
      header?.classList.add("scrolled");
    } else {
      header?.classList.remove("scrolled");
    }
  },
  { passive: true }
);


/* CURRENT YEAR */

const yearElement =
  document.querySelector("#year");

if (yearElement) {
  yearElement.textContent =
    new Date().getFullYear();
}


/* ACTIVE NAV LINK */

const sections =
  document.querySelectorAll("section[id]");

const navItems =
  document.querySelectorAll(".nav-links a");

const sectionObserver =
  new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          navItems.forEach((link) => {
            link.classList.remove("active");
          });

          const activeLink =
            document.querySelector(
              `.nav-links a[href="#${entry.target.id}"]`
            );

          activeLink?.classList.add("active");
        }
      });
    },
    {
      rootMargin: "-35% 0px -55% 0px"
    }
  );

sections.forEach((section) => {
  sectionObserver.observe(section);
});