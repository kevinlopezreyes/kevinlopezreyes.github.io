---
title: "Photos"
permalink: /photos/
layout: single
classes: wide
author_profile: false
---

<style>
.photo-intro {
  margin-bottom: 2rem;
  color: #555;
  font-size: 1.05rem;
}

.album-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.album-card {
  position: relative;
  display: block;
  width: 100%;
  height: 280px;
  padding: 0;
  overflow: hidden;
  cursor: pointer;
  border: 0;
  border-radius: 14px;
  background: #17202a;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.18);
  text-align: left;
}

.album-card img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.35s ease;
}

.album-card:hover img {
  transform: scale(1.06);
}

.album-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 1.4rem;
  color: white;
  background: linear-gradient(
    to top,
    rgba(0, 0, 0, 0.85),
    rgba(0, 0, 0, 0.05) 65%
  );
}

.album-overlay strong {
  font-size: 1.65rem;
}

.album-overlay span {
  margin-top: 0.25rem;
  font-size: 0.95rem;
  opacity: 0.9;
}

/* Visor */

.photo-viewer {
  width: min(1150px, 96vw);
  max-width: none;
  padding: 0;
  overflow: hidden;
  border: 0;
  border-radius: 12px;
  background: #111;
  color: white;
}

.photo-viewer::backdrop {
  background: rgba(0, 0, 0, 0.88);
}

.viewer-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.8rem 1.1rem;
  background: #111;
}

.viewer-title {
  margin: 0;
  color: white;
  font-size: 1.15rem;
}

.viewer-close {
  width: 42px;
  height: 42px;
  padding: 0;
  cursor: pointer;
  border: 0;
  border-radius: 50%;
  background: transparent;
  color: white;
  font-size: 2rem;
  line-height: 1;
}

.viewer-close:hover {
  background: rgba(255, 255, 255, 0.15);
}

.viewer-stage {
  display: grid;
  grid-template-columns: 60px minmax(0, 1fr) 60px;
  align-items: center;
  min-height: 500px;
  background: #080808;
}

.viewer-figure {
  margin: 0;
  text-align: center;
}

.viewer-image {
  display: block;
  width: 100%;
  max-height: 72vh;
  margin: auto;
  object-fit: contain;
}

.viewer-caption {
  min-height: 60px;
  padding: 1rem;
  color: #f4f4f4;
  background: #111;
  font-size: 1rem;
  text-align: center;
}

.viewer-arrow {
  width: 48px;
  height: 70px;
  padding: 0;
  cursor: pointer;
  border: 0;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.08);
  color: white;
  font-size: 3rem;
  line-height: 1;
}

.viewer-arrow:hover {
  background: rgba(255, 255, 255, 0.22);
}

.viewer-counter {
  padding: 0.7rem;
  color: #bbb;
  background: #111;
  font-size: 0.9rem;
  text-align: center;
}

@media (max-width: 650px) {
  .album-card {
    height: 230px;
  }

  .viewer-stage {
    grid-template-columns: 45px minmax(0, 1fr) 45px;
    min-height: 350px;
  }

  .viewer-arrow {
    width: 38px;
    height: 58px;
    font-size: 2.3rem;
  }
}
</style>

<p class="photo-intro">
  Selecciona un álbum para explorar las fotografías.
</p>

<div class="album-grid">

  <button class="album-card" type="button" data-album="japon">
    <img
      src="{{ '/assets/images/photos/japon/japon-01.jpg' | relative_url }}"
      alt="Abrir álbum de Japón"
      loading="lazy">
    <span class="album-overlay">
      <strong>Japón</strong>
      <span>Ver fotografías →</span>
    </span>
  </button>

  <button class="album-card" type="button" data-album="costa-rica">
    <img
      src="{{ '/assets/images/photos/costa-rica/costa-rica-01.jpg' | relative_url }}"
      alt="Abrir álbum de Costa Rica"
      loading="lazy">
    <span class="album-overlay">
      <strong>Costa Rica</strong>
      <span>Ver fotografías →</span>
    </span>
  </button>

</div>

<dialog class="photo-viewer" id="photo-viewer">

  <div class="viewer-header">
    <h2 class="viewer-title" id="viewer-title"></h2>
    <button
      class="viewer-close"
      id="viewer-close"
      type="button"
      aria-label="Cerrar">
      ×
    </button>
  </div>

  <div class="viewer-stage">

    <button
      class="viewer-arrow"
      id="viewer-previous"
      type="button"
      aria-label="Fotografía anterior">
      ‹
    </button>

    <figure class="viewer-figure">
      <img class="viewer-image" id="viewer-image" alt="">
      <figcaption class="viewer-caption" id="viewer-caption"></figcaption>
    </figure>

    <button
      class="viewer-arrow"
      id="viewer-next"
      type="button"
      aria-label="Fotografía siguiente">
      ›
    </button>

  </div>

  <div class="viewer-counter" id="viewer-counter"></div>

</dialog>

<script>
const albums = {
  japon: {
    title: "Japón",
    photos: [
      {
        src: "{{ '/assets/images/photos/japon/japon-01.jpg' | relative_url }}",
        caption: "Monte Fuji, Japón."
      },
      {
        src: "{{ '/assets/images/photos/japon/japon-02.jpg' | relative_url }}",
        caption: "Templo tradicional en Japón."
      },
      {
        src: "{{ '/assets/images/photos/japon/japon-03.jpg' | relative_url }}",
        caption: "Calles de Tokio durante la noche."
      }
    ]
  },

  "costa-rica": {
    title: "Costa Rica",
    photos: [
      {
        src: "{{ '/assets/images/photos/costa-rica/costa-rica-01.jpg' | relative_url }}",
        caption: "Bosque tropical de Costa Rica."
      },
      {
        src: "{{ '/assets/images/photos/costa-rica/costa-rica-02.jpg' | relative_url }}",
        caption: "Trabajo de campo en Costa Rica."
      },
      {
        src: "{{ '/assets/images/photos/costa-rica/costa-rica-03.jpg' | relative_url }}",
        caption: "Fauna observada durante el recorrido."
      }
    ]
  }
};

const viewer = document.getElementById("photo-viewer");
const viewerTitle = document.getElementById("viewer-title");
const viewerImage = document.getElementById("viewer-image");
const viewerCaption = document.getElementById("viewer-caption");
const viewerCounter = document.getElementById("viewer-counter");

let currentAlbum = null;
let currentIndex = 0;

function showPhoto() {
  const album = albums[currentAlbum];
  const photo = album.photos[currentIndex];

  viewerTitle.textContent = album.title;
  viewerImage.src = photo.src;
  viewerImage.alt = photo.caption;
  viewerCaption.textContent = photo.caption;
  viewerCounter.textContent =
    `${currentIndex + 1} de ${album.photos.length}`;
}

function openAlbum(albumName) {
  currentAlbum = albumName;
  currentIndex = 0;
  showPhoto();
  viewer.showModal();
}

function previousPhoto() {
  const total = albums[currentAlbum].photos.length;
  currentIndex = (currentIndex - 1 + total) % total;
  showPhoto();
}

function nextPhoto() {
  const total = albums[currentAlbum].photos.length;
  currentIndex = (currentIndex + 1) % total;
  showPhoto();
}

document.querySelectorAll(".album-card").forEach((card) => {
  card.addEventListener("click", () => {
    openAlbum(card.dataset.album);
  });
});

document
  .getElementById("viewer-previous")
  .addEventListener("click", previousPhoto);

document
  .getElementById("viewer-next")
  .addEventListener("click", nextPhoto);

document
  .getElementById("viewer-close")
  .addEventListener("click", () => viewer.close());

viewer.addEventListener("click", (event) => {
  if (event.target === viewer) {
    viewer.close();
  }
});

document.addEventListener("keydown", (event) => {
  if (!viewer.open) return;

  if (event.key === "ArrowLeft") previousPhoto();
  if (event.key === "ArrowRight") nextPhoto();
  if (event.key === "Escape") viewer.close();
});
</script>
