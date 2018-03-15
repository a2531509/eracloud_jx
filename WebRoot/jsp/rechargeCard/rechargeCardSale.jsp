<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $rechargeCardDataGrid;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createSysCode({id:"cardType",codeType:"CARD_TYPE"});
		$rechargeCardDataGrid = createDataGrid({
			id : "rechargeCardDataGrid",
			toolbar : "#tb",
			url : "rechargeCard/rechargeCardSaleAction!queryRechargeCard.action",
			pageSize : 20,
			onBeforeLoad:function(param){
				if(typeof(param["queryType"]) == "undefined" || param["queryType"] != 0){
					return false;
				}
			},
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
	}

	function query(){
		$rechargeCardDataGrid.datagrid("load",{
			"queryType":"0",
			"taskId":$("#taskId").val(),
			"cardType":$("#cardType").combobox("getValue"),
			"cardNo":$("#cardNo").val()
		});
	}

	function save(){
		var row = $rechargeCardDataGrid.datagrid("getSelected");
		if(row){
			if(row.USE_STATE != "未激活"){
				$.messager.alert("系统消息","充值卡【" + row.CARD_NO + "】为【" + row.USE_STATE + "】状态，不能进行操作！","error");
			}else{
				var cardNo = row.CARD_NO;
				$.messager.confirm("系统消息","您确定要进行操作吗？",function(e){
					if(e){
						$.messager.progress({text:"数据处理中，请稍后...."});
						$.post("rechargeCard/rechargeCardSaleAction!saveRechargeCard.action",{"cardNo":cardNo},function(data){
							data = eval("(" + data + ")");
							$.messager.progress("close");
							if(data.status == "0"){
								$rechargeCardDataGrid.datagrid("reload");
								showReport(data.title,data.dealNo);
							}else{
								$.messager.alert("系统消息","操作失败！" + data.errMsg,"error");
							}
						});
					}
				});
			}
		}else{
			$.messager.alert("系统消息","请选择要操作的充值卡记录！","error");
			return;
		}
	}
</script>
<n:initpage title="充值卡单张销售进行操作！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft" style="width:8%">任务号：</td>
					<td class="tableright" style="width:17%"><input type="text" name="taskId" id="taskId" class="textinput"/></td>
					<td class="tableleft" style="width:8%">卡类型：</td>
					<td class="tableright" style="width:17%"><input type="text" name="cardType" id="cardType" class="textinput"/></td>
					<td class="tableleft" style="width:8%">卡号：</td>
					<td class="tableright" style="width:17%"><input type="text" name="cardNo" id="cardNo" class="textinput"/></td>
					<td class="tableright" style="width:25%">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-readCard" plain="false" onclick="readCard();">读卡</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query();">查询</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save" plain="false" onclick="save();">保存</a>
					</td>
				</tr>
			</table>
		</div>
		<table id="rechargeCardDataGrid" title="充值卡信息"></table>
	</n:center>
</n:initpage>