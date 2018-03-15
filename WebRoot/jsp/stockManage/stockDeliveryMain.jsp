<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@ include file="/layout/initpage.jsp" %>
<%-- 
#*---------------------------------------------#
# Template for a JSP
# @version: 1.2
# @author: yangn
# @author: Jed Anderson
# @describle:功能说明： 库存配送
#---------------------------------------------#
--%>
<style>
	.panel-header{
		border-left:none;
	}
</style>
<script type="text/javascript">
	$(function(){
		createCustomSelect({
			id:"stkCode",
			value:"stk_code",
			text:"stk_name || '【' || stk_code || '】'",
			table:"stock_type",where:"stk_code is not null and stk_type = '1' ",
			isShowDefaultOption:false,
			orderby:"stk_code asc",
			from:1,
			to:30,
			defaultValue:"1100"
		});
		createSysBranch(
			{
				id:"inBrchId",
				isJudgePermission:false,
				onChange:function(newValue, oldValue){
					$("#inUserId").combobox("reload", "commAction!getAllOperators.action?branch_Id=" + newValue);
				}
			},
			{id:"inUserId"}
		);
		createSysBranch(
			{id:"brchId",isReadOnly:true},
			{id:"userId",isReadOnly:true}
		);
		//createSysBranch("brchId","userId",{},{});//,{readonly:true},{readonly:true,width:174,hasDownArrow:true}
	});
	function addRowsOpenDlg(){
		if($("#stkCode").combobox("getValue") == ""){
			$.messager.alert("系统消息","请选择将要配送的库存类型！","error",function(){
				$("#stkCode").combobox("showPanel");
			});
			return;
		}
		$.messager.progress({text : '数据处理中，请稍后....'});
		var subtitle = "",subicon = "";
		subtitle = "可供配送的任务信息";subicon = "icon-viewInfo";
		$.modalDialog({
			title:subtitle,width:740,height:300,
			iconCls:subicon,maximizable:false,maximized:true,closed:false,
			closable:false,shadow:false,inline:false,fit:false,resizable:false,
			href:"jsp/stockManage/stockDeliveryTaskView.jsp?type=" + $("#stkCode").combobox("getValue"),
			buttons:[
				{text:"确认选择",iconCls:"icon-ok",handler:function(){selectOneRow();}},
				{text:"取消选择",iconCls:"icon-cancel",handler:function(){
						$.modalDialog.handler.dialog("destroy");
						$.modalDialog.handler = undefined;
						$.messager.progress('close');
					}
				 }
			]
		});
	}
	function judgeDeliveryType(obj){
		if(obj.checked){
			if(obj.value == "1"){
				$(".taskdeliveryway").show();
				$(".cardnodeliveryway").hide();
				$("#startNo").textbox("setValue","");
				$("#endNo").textbox("setValue","");
				$("#goodsNums").textbox("setValue","");
			}else if(obj.value == "2"){
				$(".taskdeliveryway").hide();
				$("#taskIds").textbox("setValue","");
				$(".cardnodeliveryway").show();
			}
		}
	}
	function tosavestockdelivery(){
		var radios = $(":radio");
		var delieryway = "";
		radios.each(function(i, element) {
			if(element.checked == true){
				delieryway = element.value;
			}
		});
		if(dealNull(delieryway) == ""){
			$.messager.alert("系统消息","无法获取到配送方式！","error");
			return;
		}
		if($("#stkCode").combobox("getValue") == ""){
			$.messager.alert("系统消息","将选择配送的库存类型！","error",function(){
				$("#stkCode").combobox("showPanel");
			});
			return;
		}
		if(delieryway == '<s:property value="@com.erp.util.Constants@STK_DELIVERY_WAY_TASK"/>'){
			if($("#taskIds").val() == ""){
				$.messager.alert("系统消息","配送方式已选择【按任务方式配送】请选择任务编号！","error",function(){
					$("#taskIds").next().find("input").get(0).focus();
					///$("#taskIds").mouseover();
					$("#taskIds").validatebox("isValid");
				});
				return;
			}
		}
		if(delieryway == "<%=com.erp.util.Constants.STK_DELIVERY_WAY_INTERVAL%>"){
			if($("#startNo").val() == "" || $("#endNo").val() == "" || $("#goodsNums").val() == ""){
				$.messager.alert("系统消息","配送方式已选择【按号段配送】请输入起止号码和数量！","error");
				return;
			}
		}
		if($("#inBrchId").combotree("getValue") == ""){
			$.messager.alert("系统消息","请选择配送接收网点！","error",function(){
				$("#inBrchId").combotree("showPanel");
			});
			return;
		}
		if($("#inUserId").combobox("getValue") == "" || $("#inUserId").combobox("getValue") == "erp2_erp2"){
			$.messager.alert("系统消息","请选择配送接收柜员！","error",function(){
				$("#inUserId").combobox("showPanel");
			});
			return;
		}
		if($("#brchId").combotree("getValue") == ""){
			$.messager.alert("系统消息","请选择配送网点！","error",function(){
				$("#brchId").combotree("showPanel");
			});
			return;
		}
		if($("#userId").combobox("getValue") == "" || $("#userId").combobox("getValue") == "erp2_erp2"){
			$.messager.alert("系统消息","请选择配送柜员！","error",function(){
				$("#userId").combobox("showPanel");
			});
			return;
		}
		if($("#inBrchId").combotree("getValue") == $("#brchId").combotree("getValue") && $("#inUserId").combobox("getValue") == $("#userId").combobox("getValue")){
			$.messager.alert("系统消息","库存配送柜员和接收柜员不能相同！","error",function(){
				
			});
			return;
		}
		$.messager.confirm("系统消息","您确认要对" + $("#inBrchId").combotree("getText") + $("#inUserId").combobox("getText") + "进行库存配送吗？",function(r){
			if(r){
				$.messager.progress({text : '正在进行库存配送，请稍后....'});
				var formdata = getformdata("stockDelivery");
				formdata["rec.taskId"] = $("#taskIds").textbox("getValue");
				$.post("stockManage/stockManageAction!saveStockDelivery.action",formdata,function(data,status){
					$.messager.progress('close');
					if(status == "success"){
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
							if(data.status == "0"){
								
							}else{
								
							}
						 });
					}else{
						$.messager.alert("系统消息","库存配送出现错误，请重试！","error");
					}
				},"json");
			}
		});
	}
</script>
<n:initpage title="网点库管员进行配送操作！">
	<n:center cssClass="datagrid-toolbar" layoutOptions="title:'库存配送'">
		<div style="padding:2px 0,width:100%">
			<form id="stockDelivery">
				<table class="tablegrid" style="width:100%">
					<tr>
						<td class="tableleft" style="width:18%;">配送方式：</td>
						<td class="tableright" colspan="3">
							<input type="radio" name="deliveryWay" value="1" checked="checked" onclick="judgeDeliveryType(this)"/>按制卡任务配送 &nbsp;&nbsp;<!--<input type="radio" name="deliveryWay" value="2" onclick="judgeDeliveryType(this)"/>按号段配送-->
							<div>配送方式为“按制卡任务配送”时，“制卡任务”项不能为空</div>
							<div>配送方式为“按号段配送”时，库存代码不能为空，数量、起止号码必须有一项不为空。</div>
						</td>
					</tr>
					<tr>
						<td class="tableleft">库存代码：</td>
						<td class="tableright" colspan="3">
							<input id="stkCode" name="rec.stkCode" class="textinput" type="text"/>
						</td>
					</tr>
					<tr class="taskdeliveryway">
						<td class="tableleft">制卡任务：</td>
						<td class="tableright" colspan="3">
							<input name="rec.taskId" class="easyui-textbox easyui-validatebox" id="taskIds" type="text" data-options="required:true,tipPosition:'left',missingMessage:'请选择需要配送的任务信息',invalidMessage:'请选择需要配送的任务信息'" readonly="readonly"/>&nbsp;
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search"  plain="false" onclick="addRowsOpenDlg();">任务查询</a>
							<span style="color:red"> * （您可以选择多个任务一起配送）</span>
						</td>
					</tr>
					<tr class="cardnodeliveryway" style="display:none;">
						<td class="tableleft">起止号码：</td>
						<td class="tableright" colspan="3">
							<input name="rec.startNo" class="easyui-textbox easyui-validatebox" id="startNo" type="text" maxlength="20" data-options="required:true,missingMessage:'请输入卡号段的起始卡号',invalidMessage:'请输入卡号段的起始卡号'"/>-
							<input name="rec.endNo" class="easyui-textbox easyui-validatebox" id="endNo" type="text" maxlength="20" data-options="required:true,missingMessage:'请输入卡号段的截止卡号',invalidMessage:'请输入卡号段的截止卡号'"/>
						</td>
					</tr>
					<tr class="cardnodeliveryway" style="display:none;">
						<td class="tableleft">数量：</td>
						<td class="tableright" colspan="3">
							<input name="rec.goodsNums"  class="easyui-textbox easyui-validatebox" id="goodsNums" type="text" data-options="required:true,missingMessage:'请输入卡号段内的卡片数量',invalidMessage:'请输入卡号段内的卡片数量'"/>
						</td>
					</tr>
					<tr>
						<td class="tableleft">接收网点：</td>
						<td class="tableright" colspan="3">
							<input name="rec.inBrchId"  class="textinput" id="inBrchId" type="text"/>
							<label for="otherUserId" style="margin-left:10px;">接收柜员：</label>
							<input name="rec.inUserId"  class="textinput" id="inUserId" type="text"/>
						</td>
					</tr>
					<tr>
						<td class="tableleft">配送网点：</td>
						<td class="tableright" colspan="3">
							<input name="rec.brchId" class="textinput" id="brchId" type="text" value="${brchId}"/>
							<label for="userId" style="margin-left:10px;">配送柜员：</label>
							<input name="rec.userId" class="textinput" id="userId" type="text" value="${userId}"/>
						</td>
					</tr>
					<tr>
						<td colspan="1"></td>
					    <td class="tableright" colspan="3"><a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="tosavestockdelivery();">确认配送</a></td>
					</tr>
				</table>
			</form>
		</div>
	</n:center>
</n:initpage>
