const menuToggle = document.querySelector("#menu-toggle");
const navLinks = document.querySelector("#nav-links");

const filterButtons = document.querySelectorAll(".filter-button");
const projectCards = document.querySelectorAll(".project-card");

const yearElement = document.querySelector("#year");

/* Mobile Navigation */

menuToggle.addEventListener("click", () => {
  navLinks.classList.toggle("show");
});

const navigationLinks = document.querySelectorAll(".nav-links a");

navigationLinks.forEach((link) => {
  link.addEventListener("click", () => {
    navLinks.classList.remove("show");
  });
});

/* Project Filtering */

filterButtons.forEach((button) => {
  button.addEventListener("click", () => {
    const selectedFilter = button.dataset.filter;

    filterButtons.forEach((filterButton) => {
      filterButton.classList.remove("active");
    });

    button.classList.add("active");

    projectCards.forEach((card) => {
      const projectCategory = card.dataset.category;

      const shouldShow =
        selectedFilter === "all" ||
        selectedFilter === projectCategory;

      card.classList.toggle("hidden", !shouldShow);
    });
  });
});

/* Current Year in Footer */

yearElement.textContent = new Date().getFullYear();
