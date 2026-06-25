/**
 * Startpage 功能脚本
 * 提供实时时钟与搜索表单处理。
 */

/**
 * 在 #time 元素上更新当前时间（12 小时制，含上下午标记）。
 * 每秒递归调用自身以实现持续更新。
 */
function updateClock() {
	const date = new Date();
	let hours = date.getHours();
	let minutes = date.getMinutes();
	const ampm = hours >= 12 ? "pm" : "am";

	hours = hours % 12;
	hours = hours ? hours : 12;
	minutes = minutes < 10 ? "0" + minutes : minutes;
	const time = hours + ":" + minutes + " " + ampm;

	document.getElementById("time").innerHTML = time;
	setTimeout(updateClock, 1000);
}

/**
 * 为 #search-form 绑定 submit 事件监听器。
 * 阻止表单默认提交，根据选择的搜索引擎重定向到对应搜索 URL。
 *
 * 搜索引擎 URL 格式:
 * - 百度：?wd={query}
 * - 其它：?q={query}
 */
function initSearchBox() {
	document.getElementById("search-form").addEventListener("submit", (event) => {
		event.preventDefault();
		const form = event.target;
		const selectedEngine = form.engine.value;
		const query = form.q.value;

		const url =
			selectedEngine === "https://www.baidu.com/s"
				? `${selectedEngine}?wd=${encodeURIComponent(query)}`
				: `${selectedEngine}?q=${encodeURIComponent(query)}`;

		window.location.href = url;
	});
}

/** 页面加载完成后执行初始化 */
window.onload = () => {
	document.getElementById("search-bar-input").focus();
	updateClock();
	initSearchBox();
};
