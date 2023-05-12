let nextImages = [
  "/candyland.png",
  "/mojito.png",
  "/rainbow.png",
  "/santorini.png",
  "/summer.png",
];

function getRandomImage() {
  let randomNum = Math.floor(Math.random() * nextImages.length);
  return nextImages[randomNum];
}

export default getRandomImage;
