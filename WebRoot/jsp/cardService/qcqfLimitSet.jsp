<%@page language="java" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp"%>
<script type="text/javascript">
    var globalCardInfo;
	$(function(){
		$.extend($.fn.validatebox.defaults.rules, {    
		    qcAmt: {    
		        validator: function(value){ 
		        	if(isNaN(value) || value <= 0){
		        		return false;
		        	}
		            return true;    
		        },
		        message: '圈存金额必须大于 0 ！'
		    }    
		});
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"120,100",
			hasDownArrow:false,
		});
		createSysCode({
			id:"cardState",
			codeType:"CARD_STATE",
			hasDownArrow:false
		});
		createSysCode({
			id:"accKind",
			codeType:"ACC_KIND",
			hasDownArrow:false
		});
		$("#qcAmt").combobox({
			valueField:"value",
			textField:"text",
			panelHeight:"auto",
			required:true,
			value:0,
			editable:false,
			validType:"qcAmt",
			data:[
				{value:"0", text:"0"},
				{value:"200", text:"200"},
				{value:"500", text:"500"},
				{value:"1000", text:"1000"}
			]
		});
		$("#form").form({
			url:"cardService/cardServiceAction!saveAccQcLimitInfo.action",
			success:function(data){
				$.messager.progress("close");
				var json = JSON.parse(data);
				if(!json || json.status != 0){
					jAlert(json.errMsg);
					return;
				}
				jAlert("操作成功", "info");
			},
			onSubmit:function(params){
				if(!$("#form").form("validate")){
					return false;
				}
				$.messager.progress({text:"数据处理中，请稍候...."})
			}
		});
	})
	function readCard(){
		$("#form").form("reset");
		$.messager.progress({text:"正在获取卡片信息，请稍后...."});
		globalCardInfo = getcardinfo();
		if(dealNull(globalCardInfo["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + globalCardInfo["errMsg"],"error");
			return;
		}
		$("#cardNo").val(dealNull(globalCardInfo["card_No"]));
		query();
	}
	function query(){
		$.messager.progress({text:"正在加载数据，请稍后...."})
		$.post("cardService/cardServiceAction!getAccQcqfLimitInfo.action", {"limit.cardNo":$("#cardNo").val()}, function(data){
			$.messager.progress("close");
			if(!data || data.status != 0){
				jAlert(!data.errMsg ? "加载失败，未知原因" : data.errMsg);
				return;
			}
			$("#form").form("load", {
				"limit.cardNo":data.limit.cardNo,
				"limit.cardType":data.limit.cardType,
				"limit.cardState":data.limit.cardState,
				"limit.accKind":data.limit.accKind,
				"limit.name":data.limit.name,
				"limit.certNo":data.limit.certNo,
				"limit.qcLimitAmt":data.limit.qcLimitAmt,
				"limit.qtLimitAmt":data.limit.qtLimitAmt,
				"limit.qfLimitAmt":data.limit.qfLimitAmt
			});
		}, "json");
	}
	function validRmb(obj){
		var v = obj.value;
		var exp = /^\d+(\.?\d{0,2})?$/g;
		if(!exp.test(v)){
			obj.value = v.substring(0,v.length - 1);
		}else{
			var zeroexp = /^0{2,}$/g;
			if(zeroexp.test(v)){
				obj.value = 0;
			}
		}
	}
	function save(){
		$("#form").form("submit");
	}
</script>
<n:initpage>
	<n:north title="设置卡片圈存限额" />
	<n:center>
		<div id="tb" class="easyui-panel datagrid-toolbar" data-options="border:false" style="height: 100%; " title="圈存限额设置">
			<form id="form" method="post">
				<input id="readCard" type="hidden">
				<table class="tablegrid">
					<tr>
						<td class="tableleft" style="font-weight: bold">卡号:</td>
						<td class="tableright" style="width: 200px">
							<input id="cardNo" name="limit.cardNo" class="textinput easyui-validatebox" required="required">
						</td>
						<td class="tableleft" style="font-weight: bold">卡类型:</td>
						<td class="tableright" style="width: 200px">
							<input id="cardType" name="limit.cardType" class="textinput" disabled="disabled">
						</td>
						<td class="tableleft" style="font-weight: bold">卡状态:</td>
						<td class="tableright" style="width: 200px">
							<input id="cardState" name="limit.cardState" class="textinput" disabled="disabled">
						</td>
						<td class="tableright">
							<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							<a data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
						</td>
					</tr>
					<tr>
						<td class="tableleft" style="font-weight: bold">账户类型:</td>
						<td class="tableright"><input id="accKind" name="limit.accKind" class="textinput" disabled="disabled"></td>
						<td class="tableleft" style="font-weight: bold">姓名:</td>
						<td class="tableright"><input id="name" name="limit.name" class="textinput" disabled="disabled"></td>
						<td class="tableleft" style="font-weight: bold;">证件号码:</td>
						<td class="tableright"><input id="certNo" name="limit.certNo" class="textinput" disabled="disabled"></td>
						<td></td>
					</tr>
					<tr>
						<td class="tableleft" style="font-weight: bold">圈存限额（<span style="color:red;">元</span>）：</td>
						<td class="tableright"><input id="qcAmt" name="limit.qcLimitAmt" class="textinput" required="required"></td>
						<td class="tableleft" style="font-weight: bold">圈提限额（<span style="color:red;">元</span>）：</td>
						<td class="tableright"><input id="qtAmt" name="limit.qtLimitAmt" class="textinput easyui-validatebox" disabled="disabled" onkeyup="validRmb(this)"></td>
						<td class="tableleft" style="font-weight: bold;">圈付限额（<span style="color:red;">元</span>）：</td>
						<td class="tableright"><input id="qfAmt" name="limit.qfLimitAmt" class="textinput easyui-validatebox" disabled="disabled" onkeyup="validRmb(this)"></td>
						<td class="tableright">
							<a data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="save()">保存</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
	</n:center>
</n:initpage>