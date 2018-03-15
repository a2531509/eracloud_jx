<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@ include file="/layout/initpage.jsp" %>
<%-- 
#*---------------------------------------------#
# Template for a JSP
# @version: 1.2
# @author: yangn
# @author: Jed Anderson
# @describle:功能说明： 柜员领用
#---------------------------------------------#
--%>
<style>
	.panel-header{
		border-left:none;
	}
	.messager-body div{
		word-break:break-all;
	}
</style>
<script type="text/javascript">
	var $stkCode;
	$(function(){
		$stkCode = createCustomSelect({
			id:"stkCode",
			value:"stk_code",
			text:"stk_name || '【' || stk_code || '】'",
			table:"stock_type",
			where:"stk_code is not null and stk_code_state = '0' and stk_code <> '1390' ",
			isShowDefaultOption:false,
			orderby:"stk_code asc",
			from:1,
			to:30,
			defaultValue:"1100",
			onSelect:function(option){
				if(option.VALUE.charAt(0) != "1"){
					$(".taskdeliveryway").hide();
					$("#deliveryWayTask").get(0).checked = false;
					$(".cardnodeliveryway").show();
					$("#deliveryWayCardNo").get(0).checked = true;
					if(dealNull($stkCode.combobox("getValue")).charAt(0) == "1"){
						addNumberValidById("startNo");
						addNumberValidById("endNo");
					}else{
						$("#startNo").each(function(){
							this.onkeyup = function(){};
							this.onkeydown = function(){};
						});
						$("#endNo").each(function(){
							this.onkeyup = function(){};
							this.onkeydown = function(){};
						});
					}
				}else{
					$(".taskdeliveryway").show();
					$("#deliveryWayTask").get(0).checked = true;
					$(".cardnodeliveryway").hide();
					$("#deliveryWayCardNo").get(0).checked = false;
					$("#startNo").each(function(){
						this.onkeyup = function(){};
						this.onkeydown = function(){};
					}).val("");
					$("#endNo").each(function(){
						this.onkeyup = function(){};
						this.onkeydown = function(){};
					}).val("");
					addNumberValidById("startNo");
					addNumberValidById("endNo");
				}
			}
		});
		createSysBranch("inBrchId","inUserId",{isJudgePermission:false});
		createSysBranch("brchId","userId",{isReadOnly:true},{isReadOnly:true});
		$.addNumber("startNo");
		$.addNumber("endNo");
		$.addNumber("goodsNums");
	});
	function addRowsOpenDlg(){
		if($("#stkCode").combobox("getValue") == ""){
			$.messager.alert("系统消息","请选择将要领用的库存类型！","error",function(){
				$("#stkCode").combobox("showPanel");
			});
			return;
		}
		$.messager.progress({text : '数据处理中，请稍后....'});
		var subtitle = "",subicon = "";
		subtitle = "可供领用的任务信息";subicon = "icon-viewInfo";
		$.modalDialog({
			title:subtitle,width:740,height:300,
			iconCls:subicon,maximizable:false,maximized:true,closed:false,
			closable:false,shadow:false,inline:false,fit:false,resizable:false,
			href:"jsp/stockManage/tellerReceiveTaskView.jsp?type=" + $("#stkCode").combobox("getValue"),
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
				$("#startNo").val("");
				$("#endNo").val("");
				$("#goodsNums").val("");
			}else if(obj.value == "2"){
				$(".taskdeliveryway").hide();
				$("#taskIds").textbox("setValue","");
				$(".cardnodeliveryway").show();
			}
		}
		if(obj.id == "deliveryWayTask"){
			$stkCode.combobox("setValue","1100");
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
			$.messager.alert("系统消息","无法获取到领用方式！","error");
			return;
		}
		if($("#stkCode").combobox("getValue") == ""){
			$.messager.alert("系统消息","将选择领用的库存类型！","error",function(){
				$("#stkCode").combobox("showPanel");
			});
			return;
		}
		if(delieryway == '<s:property value="@com.erp.util.Constants@STK_DELIVERY_WAY_TASK"/>'){
			if($("#taskIds").val() == ""){
				$.messager.alert("系统消息","领用方式已选择【按任务方式领用】请选择任务编号！","error",function(){
					$("#taskIds").next().find("input").get(0).focus();
					///$("#taskIds").mouseover();
					$("#taskIds").validatebox("isValid");
				});
				return;
			}
		}
		if(delieryway == "<%=com.erp.util.Constants.STK_DELIVERY_WAY_INTERVAL%>"){
			if($("#startNo").val() == "" || $("#endNo").val() == "" || $("#goodsNums").val() == ""){
				$.messager.alert("系统消息","领用方式已选择【按号段领用】请输入物品起止号码和数量！","error");
				return;
			}
			if($("#stkCode").combobox("getValue").charAt(0) == "1"){
				if(dealNull($("#startNo").val()).length != 20){
					$.messager.alert("系统消息","起始卡号长度不对！","error");
					return;
				}
				if(dealNull($("#endNo").val()).length != 20){
					$.messager.alert("系统消息","截止卡号长度不对！","error");
					return;
				}
			}
		}
		if($("#inBrchId").combotree("getValue") == ""){
			$.messager.alert("系统消息","请选择领用网点！","error",function(){
				$("#inBrchId").combotree("showPanel");
			});
			return;
		}
		if($("#inUserId").combobox("getValue") == "" || $("#inUserId").combobox("getValue") == "erp2_erp2"){
			$.messager.alert("系统消息","请选择领用柜员！","error",function(){
				$("#inUserId").combobox("showPanel");
			});
			return;
		}
		if($("#brchId").combotree("getValue") == ""){
			$.messager.alert("系统消息","请选择付方网点！","error",function(){
				$("#brchId").combotree("showPanel");
			});
			return;
		}
		if($("#userId").combobox("getValue") == "" || $("#userId").combobox("getValue") == "erp2_erp2"){
			$.messager.alert("系统消息","请选择付方柜员！","error",function(){
				$("#userId").combobox("showPanel");
			});
			return;
		}
		if(dealNull($("#pwd").val()) == ""){
			$.messager.alert("系统消息","请输入领用柜员密码！","error",function(){
				$("#pwd").focus();
			});
			return;
		}
		if($("#inBrchId").combotree("getValue") == $("#brchId").combotree("getValue") && $("#inUserId").combobox("getValue") == $("#userId").combobox("getValue")){
			$.messager.alert("系统消息","领用柜员和付方柜员不能相同！","error",function(){
				
			});
			return;
		}
		$.messager.confirm("系统消息","您确认要对" + $("#inBrchId").combotree("getText") + $("#inUserId").combobox("getText") + "进行领用吗？",function(r){
			if(r){
				$.messager.progress({text : '正在进行领用，请稍后....'});
				var formdata = getformdata("tellerReceive");
				formdata["rec.taskId"] = $("#taskIds").textbox("getValue");
				$.post("stockManage/stockManageAction!saveTellerReceive.action",formdata,function(data,status){
					$.messager.progress('close');
					if(status == "success"){
						$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
							if(data.status == "0"){
								
							}else{
								
							}
						 });
					}else{
						$.messager.alert("系统消息","柜员领用出现错误，请重试！","error");
					}
				},"json");
			}
		});
	}
</script>
<n:initpage title="柜员进行库存领用操作！">
	<n:center cssClass="datagrid-toolbar" layoutOptions="title:'柜员领用'">
		<div style="padding:2px 0,width:100%">
			<form id="tellerReceive">
				<table class="tablegrid" style="width:100%">
					<tr>
						<td class="tableleft" style="width:18%;">领用方式：</td>
						<td class="tableright" colspan="3">
							<input type="radio" name="deliveryWay" value="1" id="deliveryWayTask" checked="checked" onclick="judgeDeliveryType(this)"/>按制卡任务领用 &nbsp;&nbsp;
							<input type="radio" name="deliveryWay" value="2" id="deliveryWayCardNo" onclick="judgeDeliveryType(this)"/>按号段领用
							<div>领用方式为“按制卡任务领用”时，“制卡任务”项不能为空</div>
							<div>领用方式为“按号段领用”时，库存代码不能为空，数量、起止号码必须有一项不为空。</div>
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
							<input name="rec.taskId" class="easyui-textbox easyui-validatebox" id="taskIds" type="text" data-options="required:true,tipPosition:'left',missingMessage:'请选择需要领用的任务信息',invalidMessage:'请选择需要领用的任务信息'" readonly="readonly"/>&nbsp;
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search"  plain="false" onclick="addRowsOpenDlg();">任务查询</a>
							<span style="color:red"> * （您可以选择多个任务一起领用）</span>
						</td>
					</tr>
					<tr class="cardnodeliveryway" style="display:none;">
						<td class="tableleft">起止号码：</td>
						<td class="tableright" colspan="3">
							<input name="rec.startNo" class="easyui-validatebox textinput" id="startNo" type="text" maxlength="20" data-options="validType:'maxLength[20]',required:true,missingMessage:'请输入卡号段的起始卡号',invalidMessage:'请输入卡号段的起始卡号',tipPosition:'left'"/>
							&nbsp;&nbsp;-&nbsp;&nbsp;
							<input name="rec.endNo" class="easyui-validatebox textinput" id="endNo" type="text" maxlength="20" data-options="validType:'maxLength[20]',required:true,missingMessage:'请输入卡号段的截止卡号',invalidMessage:'请输入卡号段的截止卡号'"/>
						</td>
					</tr>
					<tr class="cardnodeliveryway" style="display:none;">
						<td class="tableleft">数量：</td>
						<td class="tableright" colspan="3">
							<input name="rec.goodsNums"  class="easyui-validatebox textinput" id="goodsNums" type="text" maxlength="5" data-options="required:true,validType:['number'],missingMessage:'请输入卡号段内的卡片数量',invalidMessage:'请输入卡号段内的卡片数量'"/>
						</td>
					</tr>
					<tr>
						<td class="tableleft">领用网点：</td>
						<td class="tableright" colspan="3">
							<input name="rec.inBrchId"  class="textinput" id="inBrchId" type="text"/>
							<label for="otherUserId" style="margin-left:10px;">领用柜员：</label>
							<input name="rec.inUserId"  class="textinput" id="inUserId" type="text"/>
							<label for="pwd" style="margin-left:10px;">收方密码：</label>
							<input type="password" name="pwd" id="pwd" class="textinput" maxlength="6">
						</td>
					</tr>
					<tr>
						<td class="tableleft">付方网点：</td>
						<td class="tableright" colspan="3">
							<input name="rec.brchId" class="textinput" id="brchId" type="text" value="${brchId}"/>
							<label for="userId" style="margin-left:10px;">付方柜员：</label>
							<input name="rec.userId" class="textinput" id="userId" type="text" value="${userId}"/>
						</td>
					</tr>
					<tr>
						<td colspan="1"></td>
					    <td class="tableright" colspan="3"><a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="tosavestockdelivery();">确认领用</a></td>
					</tr>
					<tr>
						<td class="tableleft">&nbsp;</td>
						<td class="tableright" colspan="3" style="color:red;font-family:'微软雅黑'">
							<p>1、柜员领用可采取两种方式，按照【任务方式】进行领用；按照【物品号段方式】进行领用；</p>
							<p>2、按照任务方式进行领用时，请确保选择任务是【已接收】状态且任务库存明细全部在当前柜员名下才能领用成功，否则领用失败；</p>
							<p>3、按照号段方式进行领用时，请确保输入<span style="text-decoration:underline;font-style:italic;color:green;font-weight:600;">同一个任务内的连续号段且全部在当前柜员名下</span>，否则领用失败，分拆的任务包不能在按照任务方式进行领用；</p>
						</td>
					</tr>
				</table>
			</form>
		</div>
	</n:center>
</n:initpage>