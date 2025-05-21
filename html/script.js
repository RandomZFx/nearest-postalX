let isEditing = false;
let offsetX, offsetY;
let isDragging = false;

const container = document.getElementById('postal-container');

container.addEventListener('mousedown', (e) => {
  if (!isEditing) return;
  isDragging = true;
  offsetX = e.clientX - container.getBoundingClientRect().left;
  offsetY = e.clientY - container.getBoundingClientRect().top;
});

document.addEventListener('mousemove', (e) => {
  if (isDragging) {
    const x = e.clientX - offsetX;
    const y = e.clientY - offsetY;
    container.style.left = `${x}px`;
    container.style.top = `${y}px`;
    container.style.position = 'absolute';
  }
});

document.addEventListener('mouseup', (e) => {
  if (isDragging) {
    isDragging = false;
    const x = container.offsetLeft;
    const y = container.offsetTop;
    savePosition(x, y);
  }
});

document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      fetch(`https://${GetParentResourceName()}/exitEditMode`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      });
    }
  });
  

function enableEditMode() {
  isEditing = true;
  container.style.outline = '2px dashed lime';
  container.style.cursor = 'move';
}

function disableEditMode() {
  isEditing = false;
  container.style.outline = 'none';
  container.style.cursor = 'default';
}

function savePosition(x, y) {
  fetch(`https://${GetParentResourceName()}/savePosition`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ x, y })
  }).catch((e) => console.error("Failed to send savePosition:", e));
}

window.addEventListener('message', function (event) {
  const data = event.data;

  if (data.type === 'updatePostal') {
    container.querySelector('#postal-text').textContent = `Nearest Postal: ${data.postal} | ${data.distance}km`;
  } else if (data.type === 'toggleUI') {
    container.style.display = data.show ? 'block' : 'none';
  } else if (data.type === 'enableEdit') {
    enableEditMode();
  } else if (data.type === 'disableEdit') {
    disableEditMode();
  } else if (data.type === 'loadPosition') {
    container.style.left = `${data.x}px`;
    container.style.top = `${data.y}px`;
    container.style.position = 'absolute';
  }
});
