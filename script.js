document.addEventListener('DOMContentLoaded', fetchData);

function fetchData() {
  fetch('YOUR_SERVERLESS_API_ENDPOINT')
    .then(response => response.json())
    .then(data => {
      const dataList = document.getElementById('dataList');
      dataList.innerHTML = ''; // Clear previous data
      
      data.forEach(item => {
        const li = document.createElement('li');
        li.textContent = item;
        dataList.appendChild(li);
      });
    })
    .catch(error => {
      console.error('Error fetching data:', error);
    });
}
