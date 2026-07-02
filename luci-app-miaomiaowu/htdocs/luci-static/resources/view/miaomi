'use strict';
'require view';
'require form';
'require uci';
'require rpc';

var callServiceList = rpc.declare({
	object: 'service',
	method: 'list',
	params: ['name'],
	expect: { '': {} }
});

function getServiceStatus() {
	return callServiceList('miaomiaowu').then(function (res) {
		var running = false;
		try {
			running = res['miaomiaowu']['instances']['instance1']['running'];
		} catch (e) {}
		return running;
	});
}

return view.extend({
	load: function () {
		return Promise.all([uci.load('miaomiaowu'), getServiceStatus()]);
	},

	render: function (data) {
		var running = data[1];
		var m, s, o;

		m = new form.Map('miaomiaowu', _('妙妙屋'), _('Clash 配置订阅管理工具') +
			'<br /><span style="color:' + (running ? '#5cb85c' : '#d9534f') + '">' +
			(running ? _('● 运行中') : _('● 未运行')) + '</span>');

		s = m.section(form.NamedSection, 'miaomiaowu', 'miaomiaowu', _('基本设置'));
		s.anonymous = true;

		o = s.option(form.Flag, 'enabled', _('启用'));
		o.default = '1';
		o.rmempty = false;

		o = s.option(form.Value, 'port', _('监听端口'));
		o.datatype = 'port';
		o.default = '8080';

		o = s.option(form.Value, 'database_path', _('数据库路径'), _('SQLite 数据库文件存放路径'));
		o.default = '/etc/mmw/traffic.db';
		o.rmempty = false;

		o = s.option(form.ListValue, 'log_level', _('日志级别'));
		o.value('debug', 'debug');
		o.value('info', 'info');
		o.value('warn', 'warn');
		o.value('error', 'error');
		o.default = 'info';

		return m.render();
	}
});
