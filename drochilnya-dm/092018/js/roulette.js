var wrap = $('.roulette-prizes');
var container = $('.roulette-wrap');
var btn = $('#spin');
var prizeImage = $('#prize-image');
var prizeName = $('#prize-name');
var sellButton = $('#sell-prize');
var getButton = $('#get-prize');
var balance = $('#balance');
var lastSpin = 0;
var sound = document.getElementById('roulette-sound');

var responsiveOffset = 0;

var containerWidth = container.innerWidth()
if(containerWidth < 800) {
	responsiveOffset = 400-(containerWidth/2);
	wrap.css({marginLeft:((-1)*responsiveOffset) + 'px'});
}

function getPrize(id) {
	$.getJSON('/roulette/get_prize?spin=' + id).done(function(response) {
		if(response.status == undefined || response.status == 0) {
			$.notify(response.message,{position:'bottom right',style:'radmir-crmp',className:'error'});
			return;
		}
		$.notify(response.message,{position:'bottom right',style:'radmir-crmp',className:'success'});
	});
	$('#win').modal('hide');
}

function sellPrize(id) {
	$.getJSON('/roulette/sell_prize?spin=' + id).done(function(response) {
		if(response.status == undefined || response.status == 0) {
			$.notify(response.message,{position:'bottom right',style:'radmir-crmp',className:'error'});
			return;
		}			
		balance.text(response.balance);
		$.notify('Вы обменяли приз. Ваш баланс ' + response.balance + ' руб.',{position:'bottom right',style:'radmir-crmp',className:'success'});
	});
	$('#win').modal('hide');
}

getButton.click(function() {
	getPrize(lastSpin);
});

sellButton.click(function() {
	sellPrize(lastSpin);
})

btn.click(function() {
	btn.addClass('loading');
	btn.attr('disabled',true);
	$.getJSON('/roulette/spin').done(function(response) {
		if(response.status == undefined || response.status == 0) {
			$.notify(response.message,{position:'bottom right',style:'radmir-crmp',className:'error'});
			btn.removeClass('loading');
			btn.attr('disabled',false);				
			return;
		}
		wrap.children().each(function(i,el) {
			el.remove();
		});
		response.prizes.forEach(function(item,i) {
			var prize = document.createElement('div');
			var prizeName = document.createElement('div');
			prize.classList.add('prize');
			prize.style.backgroundImage = 'url("/092018/images/roulette_prizes/' + item.img + '.png")';
			prizeName.classList.add('prize-name');
			prizeName.innerText = item.name;
			wrap.append(prize);
			prize.append(prizeName);
		});

		prizeImage.css({backgroundImage:'url("/092018/images/roulette_prizes/' + response.prize.img + '.png")'});

		if(response.prize.type == 'cash')
			prizeName.text(response.count + ' руб.');

		else if(response.prize.type == 'exp')
			prizeName.text(response.count + ' EXP');

		else if(response.prize.type == 'weapon')
			prizeName.text(response.prize.name + ' (' + response.count + ' патронов)');

		else if(response.prize.type == 'skill' && response.id != 13)
			prizeName.text('Навык владения ' + response.prize.name + ' 100%');

		else if(response.prize.type == 'skill' && response.id == 13)
			prizeName.text('Все скиллы 100%');

		else if(response.prize.type == 'skin')
			prizeName.text(response.prize.name);

		else if(response.prize.type == 'vehicle')
			prizeName.text(response.prize.name);

		else if(response.prize.type == 'vip')
			prizeName.text('Премиум аккаунт на ' + response.count + ' дн.');

		sellButton.text('Продать за ' + response.sellPrice + ' монет');

		lastSpin = response.lastSpin;

		var centerPx = -160*50 - responsiveOffset;
		var floatPx = Math.random() > 0.5 ? centerPx + Math.round(Math.random()*50) : centerPx -Math.round(Math.random()*50);
		wrap.css({marginLeft:0});
		sound.play();
		setTimeout(function() {
			sound.pause();
			sound.currentTime = 0;
		},6000);
		wrap.animate({marginLeft:floatPx + 'px'},7000,'easeOutCirc',function() {
			wrap.animate({marginLeft:centerPx + 'px'},500,function() {
				$('#win').modal('show');
				if(free != 0) {
					free -= 1;
					if(free == 0) {
						btn.text('Начать игру').css({fontSize:'16px'});
					}
				}
				btn.removeClass('loading');
				btn.attr('disabled',false);
			});
		});

		balance.text(response.balance);
	});
});