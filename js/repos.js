import {snippets} from "./snippets.js";

var innerContent = document.getElementsByClassName("inner-content")[0]
let repos = [
    {
        id: 1,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asap-mods.github.io/compile/ada\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">Ada <i class=\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
        url: "https://asapmods.github.io/compile/ada"    
    },
    {
        id: 2,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asap-mods.github.io/compile/assembly\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">Assembly <i class=\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
        url: "https://asapmods.github.io/compile/assembly"
    },
    {
        id: 3,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asap-mods.github.io/compile/c%23\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">C# <i class=\"style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
        url: "https://asapmods.github.io/compile/c%23"
    },
    {
        id: 4,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asap-mods.github.io/compile/c++(gcc)\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">C++(gcc) <i class=\"style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
        url: "https://asapmods.github.io/compile/c++(gcc)"
    },
    {
        id: 5,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asap-mods.github.io/compile/lua\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">Lua <i class=\"style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
        url: "https://asapmods.github.io/compile/lua"
    },
    {
        id: 6,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asap-mods.github.io/compile/node-js\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">Node.js <i class=\"style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
        url: "https://asapmods.github.io/compile/node-js"
    },
    {
        id: 7,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asap-mods.github.io/compile/Pascal\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">Pascal <i class=\"style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
        url: "https://asapmods.github.io/compile/Pascal"
    },
    {
        id: 8,
        title: "Online compile",
        desc: "Онлайн компилятор языка <a href=\"https://asap-mods.github.io/compile/python\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">Python <i class=\"style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a>",
        url: "https://asapmods.github.io/compile/python"
    },
]

if(innerContent) {
    for (var i = 0; i < repos.length; i++) {
        var reposObj = repos[i]
        var reposStr = `<div class="repos-element" id="repos-${reposObj.id}">
    <div class="info">
        <p class="title">${reposObj.title}</p>
        ${reposObj.desc.replace(/\n/g,"<br>")}
    </div>
    <a class="download" href="${reposObj.url}" <p>Открыть</p></a>
</div>`
        innerContent.innerHTML += reposStr
    }
}
