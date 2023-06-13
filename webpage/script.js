var character = document.getElementById("character");
var block = document.getElementById("block");
var counter = 0;
var bestScore = 0;
var isGameOver = false;

// Function to handle character jumps
function jump() {
  if (character.classList == "animate" || isGameOver) {
    return;
  }
  character.classList.add("animate");
  setTimeout(function () {
    character.classList.remove("animate");
  }, 300);
}

// Function to check collision and update score
function checkCollision() {
  let characterTop = parseInt(
    window.getComputedStyle(character).getPropertyValue("top")
  );
  let blockLeft = parseInt(
    window.getComputedStyle(block).getPropertyValue("left")
  );
  if (blockLeft < 20 && blockLeft > -20 && characterTop >= 130) {
    // Collision detected
    isGameOver = true;
    block.style.animation = "none";
    var score = Math.floor(counter / 100);
    if (score > bestScore) {
      bestScore = score;
      document.getElementById("scorebest").innerHTML = bestScore;
    }
    var playerName = prompt("Game Over. Enter your name:");
    if (playerName) {
      handleNewHighScore(playerName, score);
      updateTeamSequoia();
    }
    counter = 0;
    block.style.animation = "block 1s infinite linear";
    isGameOver = false;
  } else {
    counter++;
    document.getElementById("scoreSpan").innerHTML = Math.floor(counter / 100);
  }
}

// Function to start the game
function startGame() {
  setInterval(checkCollision, 10);
}

// Function to handle new high scores
async function handleNewHighScore(playerName, score) {
  // Add new entry to Team-Sequoia data
  TeamSequoiaData.push({
    rank: TeamSequoiaData.length + 1,
    name: playerName,
    score: score,
  });

  // Sort the Team-Sequoia data based on score (descending order)
  TeamSequoiaData.sort(function (a, b) {
    return b.score - a.score;
  });

  // Truncate the Team-Sequoia data to a maximum of 10 entries
  TeamSequoiaData = TeamSequoiaData.slice(0, 10);

  // Call the API endpoint to update the Team-Sequoia in DynamoDB
  try {
    const response = await fetch('API_ENDPOINT_URL', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(TeamSequoiaData),
    });

    if (response.ok) {
      console.log('Team-Sequoia data successfully updated in DynamoDB');
    } else {
      console.error('Failed to update Team-Sequoia data in DynamoDB');
    }
  } catch (error) {
    console.error('Error occurred while updating Team-Sequoia data:', error);
  }
}

// Function to update the Team-Sequoia HTML
function updateTeamSequoia() {
  var TeamSequoiaTable = document.getElementById("Team-Sequoia");

  // Clear existing Team-Sequoia rows
  while (TeamSequoiaTable.rows.length > 1) {
    TeamSequoiaTable.deleteRow(1);
  }

  // Add new rows to the Team-Sequoia table
  TeamSequoiaData.forEach(function (entry) {
    var row = TeamSequoiaTable.insertRow();
    row.insertCell().textContent = entry.rank;
    row.insertCell().textContent = entry.name;
    row.insertCell().textContent = entry.score;
  });
}
