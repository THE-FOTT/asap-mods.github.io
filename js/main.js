//Получаем объекты

//Плеер

var videoPlayer = document.getElementById('video-player');

//Время

var progressBar = document.getElementById('video-hud__progress-bar');

var currTime = document.getElementById('video-hud__curr-time');

var durationTime = document.getElementById('video-hud__duration');

//Кнопки

var actionButton = document.getElementById('video-hud__action');

var muteButton = document.getElementById('video-hud__mute');

var volumeScale = document.getElementById('video-hud__volume');

var speedSelect = document.getElementById('video-hud__speed');

function videoAct() { //Запускаем или ставим на паузу

if(videoPlayer.paused) {

videoPlayer.play();

actionButton.setAttribute('class','video-hud__element video-hud__action video-hud__action_play');

} else {

videoPlayer.pause();

actionButton.setAttribute('class','video-hud__element video-hud__action video-hud__action_pause');

}

if(durationTime.innerHTML == '00:00') {

durationTime.innerHTML = videoTime(videoPlayer.duration); //Об этой функции чуть ниже

}

}

//Запуск, пауза

actionButton.addEventListener('click',videoAct);

videoPlayer.addEventListener('click',videoAct);

function videoTime(time) { //Рассчитываем время в секундах и минутах

time = Math.floor(time);

var minutes = Math.floor(time / 60);

var seconds = Math.floor(time - minutes * 60);

var minutesVal = minutes;

var secondsVal = seconds;

if(minutes < 10) {

minutesVal = '0' + minutes;

}

if(seconds < 10) {

secondsVal = '0' + seconds;

}

return minutesVal + ':' + secondsVal;

}

function videoProgress() { //Отображаем время воспроизведения

progress = (Math.floor(videoPlayer.currentTime) / (Math.floor(videoPlayer.duration) / 100));

progressBar.value = progress;

currTime.innerHTML = videoTime(videoPlayer.currentTime);

}

function videoChangeTime(e) { //Перематываем

var mouseX = Math.floor(e.pageX - progressBar.offsetLeft);

var progress = mouseX / (progressBar.offsetWidth / 100);

videoPlayer.currentTime = videoPlayer.duration * (progress / 100);

}

//Отображение времени

videoPlayer.addEventListener('timeupdate',videoProgress);

//Перемотка

progressBar.addEventListener('click',videoChangeTime);

function videoChangeVolume() { //Меняем громкость

var volume = volumeScale.value / 100;

videoPlayer.volume = volume;

if(videoPlayer.volume == 0) {

muteButton.setAttribute('class','video-hud__element video-hud__mute video-hud__mute_true');

} else {

muteButton.setAttribute('class','video-hud__element video-hud__mute video-hud__mute_false');

}

}

function videoMute() { //Убираем звук

if(videoPlayer.volume == 0) {

videoPlayer.volume = volumeScale.value / 100;

muteButton.setAttribute('class','video-hud__element video-hud__mute video-hud__mute_false');

} else {

videoPlayer.volume = 0;

muteButton.setAttribute('class','video-hud__element video-hud__mute video-hud__mute_true');

}

}

function videoChangeSpeed() { //Меняем скорость

var speed = speedSelect.value / 100;

videoPlayer.playbackRate = speed;

}

//Звук

muteButton.addEventListener('click',videoMute);

volumeScale.addEventListener('change',videoChangeVolume);

//Работа со скоростью

speedSelect.addEventListener('change',videoChangeSpeed);