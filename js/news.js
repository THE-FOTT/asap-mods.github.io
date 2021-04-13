import {snippets} from "./snippets.js";

var innerContent = document.getElementsByClassName("inner-content")[0]
let news = [
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
    {
        id: 1,
        title: "asapmods website",
        desc: "теперь оффициально доступен сайт <a href=\"https://vk.com/asapmods\" style=\"color: rgb(255, 7, 112); text-decoration: none; font-weight: bold;\">asapmods <i class=\"fas fa-check\" style=\"font-size: 12px; color: rgb(255, 7, 112);\"></i></a> Ураааа",
    },
]

if(innerContent) {
    for (var i = 0; i < news.length; i++) {
        var newsObj = news[i]
        var newsStr = `<div class="news-element" id="news-${newsObj.id}">
    <p class="title">${newsObj.title}</p>
    ${newsObj.desc.replace(/\n/g,"<br>")}
</div>`
        innerContent.innerHTML += newsStr
    }
}