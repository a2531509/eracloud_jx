<%@page language="java" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp"%>
<script type="text/javascript">
	$(function(){
		$("#flag").combobox({
			valueField:"value",
			textField:"text",
			panelHeight:"auto",
			editable:false,
			data:[
				{value:"", text:"请选择"},
				{value:"0", text:"已返还"},
				{value:"1", text:"未返还"}
			]
		});
		
		$("#dg").datagrid({
			url:"cardService/cardServiceAction!queryCardAccBalReturn.action",
			pagination:true,
			pageSize:20,
			toolbar:$("#tb"),
			fit:true,
			border:false,
			fitColumns:true,
			singleSelect:true,
			rownumbers:true,
			striped:true,
			frozenColumns:[[
				{field:"", checkbox:true},
				{field:"DEAL_NO", title:"业务流水", sortable:true, width:parseInt($(this).width() * 0.06)},
				{field:"CUSTOMER_ID", title:"客户编号", sortable:true, width:parseInt($(this).width() * 0.08), hidden:true},
				{field:"CUSTOMER_NAME", title:"客户姓名", sortable:true, width:parseInt($(this).width() * 0.05)},
				{field:"CERT_NO", title:"证件号码", sortable:true, width:parseInt($(this).width() * 0.12)},
				{field:"CARD_NO", title:"卡号", sortable:true, width:parseInt($(this).width() * 0.13)},
				{field:"BANK_CARD_NO", title:"银行卡号", sortable:true, width:parseInt($(this).width() * 0.13)},
				{field:"AMT", title:"返还金额", sortable:true, width:parseInt($(this).width() * 0.05), formatter:function(value){
					return $.foramtMoney(Number(value).div100());
				}}
			]],
			columns:[[
				{field:"FLAG", title:"返还状态", sortable:true, formatter:function(value){
					if(value == "0"){
						return "<span style='color:green'>已返还</span>";
					} else if(value == "1"){
						return "<span style='color:orange'>未返还</span>";
					}
				}},
				{field:"DEAL_TIME", title:"登记时间", sortable:true},
				{field:"BRCH_NAME", title:"登记网点", sortable:true, width:parseInt($(this).width() * 0.2)},
				{field:"USER_ID", title:"登记柜员", sortable:true},
				{field:"NOTE", title:"备注", sortable:true, width:parseInt($(this).width() * 0.2)}
			]],
			onLoadSuccess:function(data){
				if(data.status != "0"){
					jAlert(data.errMsg, "warning");
				}
			},
			onBeforeLoad:function(params){
				/* if(!params.query){
					return false;
				} */
			}
		});
	})
	
	function query(){
		var dealNo = $("#dealNo").val();
		var name = $("#name").val();
		var certNo = $("#certNo").val();
		var cardNo = $("#cardNo").val();
		
		$("#dg").datagrid("load", {
			query:true,
			dealNo:dealNo,
			name:name,
			certNo:certNo,
			cardNo:cardNo,
			returnState:$("#flag").combobox("getValue")
		});
	}
	
	function returnConfirm(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(!selection || selection.length != 1){
			jAlert("请选择一条记录", "warning");
			return;
		}
		
		if(selection[0].FLAG == 0){
			jAlert("余额返还已确认", "warning");
			return;
		}
		
		$.messager.confirm("系统消息", "确认余额返现记录 [业务流水:" + selection[0].DEAL_NO + ", 卡号:" + selection[0].CARD_NO + "] 已返还？", function(r){
			if(r){
				$.post("cardService/cardServiceAction!confirmCardAccBalReturn.action", {dealNo:selection[0].DEAL_NO}, function(data){
					if(data.status == 0){
						jAlert("余额返现确认成功");
					} else {
						jAlert("余额返现确认失败, " + data.errMsg);
					}
				}, "json");
			}
		});
	}
	
	function cancel(){
		var selection = $("#dg").datagrid("getSelections");
		
		if(!selection || selection.length != 1){
			jAlert("请选择一条记录", "warning");
			return;
		}
		
		if(selection[0].FLAG == 0){
			jAlert("余额返还已确认", "warning");
			return;
		}
		
		$.messager.confirm("系统消息", "确认撤销余额返现记录【业务流水:" + selection[0].DEAL_NO + ", 卡号:" + selection[0].CARD_NO + "】？", function(r){
			if(r){
				$.post("cardService/cardServiceAction!cancelCardAccBalReturn.action", {dealNo:selection[0].DEAL_NO}, function(data){
					if(data.status == 0){
						jAlert("余额返现撤销成功", "info", function(){
							query();
						});
					} else {
						jAlert("余额返现撤销失败, " + data.errMsg);
					}
				}, "json");
			}
		});
	}
</script>
<n:initpage>
	<n:north title="查询余额返现登记记录以及进行余额返现操作" />
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<table class="tablegrid">
				<tr>
					<td class="tableleft">业务流水</td>
					<td class="tableright"><input id="dealNo" class="textinput"></td>
					<td class="tableleft">姓名</td>
					<td class="tableright"><input id="name" class="textinput"></td>
					<td class="tableleft">证件号码</td>
					<td class="tableright"><input id="certNo" class="textinput"></td>
					<td class="tableleft">卡号</td>
					<td class="tableright"><input id="cardNo" class="textinput"></td>
				</tr>
				<tr>
					<td class="tableleft">返还状态</td>
					<td class="tableright"><input id="flag" class="textinput"></td>
					<td class="tableright" colspan="6" style="padding-left: 20px">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query()">查询</a>
						<shiro:hasPermission name="cardAccBalReturnConfirm">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-back" plain="false" onclick="cancel()">撤销</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-ok" plain="false" onclick="returnConfirm()">返还确认</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
		<table id="dg" title="余额返现登记信息" style="width: 100%"></table>
	</n:center>
</n:initpage>