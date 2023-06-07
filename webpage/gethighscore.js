export const snakeget = "https://l6eyjy00sb.execute-api.us-east-1.amazonaws.com/prod/{proxy+}";

export async function gethighscores() {
  try {
    const response = await fetch(shrekget);
    const data = await response.json();

    // Map each object in the data array to a new object with properties playername and highscore
    const highscores = data.map(item => ({
      playername: item.playername.S,
      highscore: parseInt(item.highscore.N)
    }));

    return highscores;
  } catch (error) {
    console.log(error);
    return null;
  }
}
gethighscores().then((data) => console.log(data)).catch((error) => console.error(error));