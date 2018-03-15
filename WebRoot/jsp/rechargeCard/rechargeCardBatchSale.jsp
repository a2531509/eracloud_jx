<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $rechargeCardDataGrid;
	$(function(){
		$rechargeCardDataGrid = createDataGrid({
			id : "rechargeCardDataGrid",
			toolbar : "#tb",
			pagination : false,
			singleSelect : false,
			columns:[[
				{field:"V_V",checkbox:true},
				{field:"TASK_ID",title:"任务号",align:"center",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"ORG_ID",title:"机构代码",align:"center",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"CARD_TYPE",title:"卡类型",align:"center",sortable:true,width:parseInt($(this).width()*0.10)},
				{field:"CARD_NO",title:"卡号",align:"center",sortable:true,width:parseInt($(this).width()*0.15)},
				{field:"FACE_VAL",title:"充值面额（元）",align:"center",sortable:true,width:parseInt($(this).width()*0.08),
					formatter:function(value,row,index){
						return Number(value).div100();
					}
				},
				{field:"USE_STATE",title:"使用状态",align:"center",sortable:true,width:parseInt($(this).width()*0.10)},
			]]
		});
	});

	function readCard(){
		$.messager.progress({text:"正在获取卡信息，请稍后...."});
		cardmsg = getcardinfo();
		if(dealNull(cardmsg["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
			return;
		}
		$.messager.progress("close");
		$("#cardNo").val(cardmsg["card_No"]);
		validateCard();
	}
	
	function validateCard() {
		$.post("rechargeCard/rechargeCardSaleAction!getRechargeCardInfo.action","cardNo=" + $("#cardNo").val(),function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				if(dealNull(data.errorMsg) != ""){
					$.messager.alert("系统消息","验证充值卡信息发生错误：" + data.errorMsg ,"error");
					return;
				}else{
					var rows = $("#rechargeCardDataGrid").datagrid("getRows");
					for(var index=0;index<rows.length;index++){
						if(rows[index].CARD_NO == data.cardRecharge.cardNo){
							return;
						}
					}
					$("#rechargeCardDataGrid").datagrid("appendRow",{
						TASK_ID:data.cardRecharge.taskId,
						ORG_ID:data.cardRecharge.orgId,
						CARD_TYPE:data.cardRecharge.cardType,
						CARD_NO:data.cardRecharge.cardNo,
						FACE_VAL:data.cardRecharge.faceVal,
						USE_STATE:data.cardRecharge.useState
					});
					if(data.cardRecharge.useState == "未激活"){
						$("#rechargeCardDataGrid").datagrid("checkRow", rows.length - 1);
					}
				}
			}else{
				$.messager.alert("系统消息","验证充值卡信息时出现错误，请重试...","error");
			}
		},"json").error(function(){
			$.messager.alert("系统消息","验证充值卡信息时出现错误，请重试...","error");
		});
		$("#cardNo").val("");
	}

	function batchSave(){
		var row = $rechargeCardDataGrid.datagrid("getChecked");
		if(row && row.length > 0){
			var cardNos = "";
			var count = 0;
			var errorMsg = "";
			for(var index=0;index<row.length;index++){
				if(row[index].USE_STATE == "未激活") {
					count++;
					cardNos += "'" + row[index].CARD_NO + "'";
					if(index != row.length - 1){
						cardNos += ",";
					}
				}else{
					if(errorMsg != "") {
						errorMsg += ",<br/>";
					}
					errorMsg += "充值卡【" + row[index].CARD_NO + "】为【" + row[index].USE_STATE + "】状态";
				}
			}
			var confirmMsg = "已选择：" + count + "张充值卡！<br/>";
			if(errorMsg != ""){
				confirmMsg += "其中以下充值卡不能进行保存操作！原因：<br/>" + errorMsg + "<br/>"
			}
			if(count != 0){
				confirmMsg += "<br/>您确定要进行操作吗？"
				$.messager.confirm("系统消息",confirmMsg,function(e){
					if(e){
						$.messager.progress({text:"数据处理中，请稍后...."});
						$.post("rechargeCard/rechargeCardSaleAction!batchSaveRechargeCard.action",{"cardNos":cardNos},function(data){
							data = eval("(" + data + ")");
							$.messager.progress("close");
							if(data.status == "0"){
								for(var index=0;index<row.length;index++){
									var position=$("#rechargeCardDataGrid").datagrid("getRowIndex",row[index]);
									$("#rechargeCardDataGrid").datagrid("deleteRow",position);
								}
								showReport(data.title,data.dealNo);
							}else{
								$.messager.alert("系统消息","操作失败！" + data.errMsg,"error");
							}
						});
					}
				});
			}else{
				$.messager.alert("系统消息","请选择充值卡为【未激活】状态的记录！","error");
			}
		}else{
			$.messager.alert("系统消息","请选择要操作的充值卡记录！","error");
			return;
		}
	}

</script>
<n:initpage title="充值卡批量销售">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft" style="width:8%">卡号：</td>
					<td class="tableright" style="width:17%"><input type="text" name="cardNo" id="cardNo" class="textinput" readonly="readonly"/></td>
					<td class="tableright" style="width:50%">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-readCard" plain="false" onclick="readCard();">读卡</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save" plain="false" onclick="batchSave();">批量保存</a>
					</td>
				</tr>
			</table>
		</div>
		<table id="rechargeCardDataGrid" title="充值卡信息"></table>
	</n:center>
</n:initpage>