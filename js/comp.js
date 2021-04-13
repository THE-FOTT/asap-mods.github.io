import {snippets} from "./snippets.js";

var innerContent = document.getElementsByClassName("inner1-content")[0]
let news = [
    {
        id: 1,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asapmods.github.io/compile/ada\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">Ada <i class=\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
    },
    {
        id: 2,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asapmods.github.io/compile/assembly\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">Assembly <i class=\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
    },
    {
        id: 3,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asapmods.github.io/compile/c#\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">C# <i class=\"style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
    },
    {
        id: 4,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asapmods.github.io/compile/c++(gcc)\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">C++(gcc) <i class=\"style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
    },
]

if(innerContent) {
    for (var i = 0; i < news.length; i++) {
        var newsObj = news[i]
        var newsStr = `<div class="news1-element" id="news-${newsObj.id}">
    <p class="title">${newsObj.title}</p>
    ${newsObj.desc.replace(/\n/g,"<br>")}
</div>`
        innerContent.innerHTML += newsStr
    }
}