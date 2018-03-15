<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>卡内信息查询</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">   
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<style type="text/css">
		.label_left{text-align:right;padding-right:2px;height:30px;font-weight:700;}
		.label_right{text-align:left;padding-left:2px;height:30px;}
		#tb table,#tb table td{border:1px dotted rgb(149, 184, 231);}
		#tb table{border-left:none;border-right:none;}
		body{font-family:'微软雅黑'}
	</style> 
	<script type="text/javascript">
		var cardinfo;
		var rechargeinfo;
		var comsumeinfo;
		$(function(){
			rechargeinfo = $("#rechargeinfo").datagrid({
				border:false,
				striped:true,
				//height:26*11,
				fit:true,
				fitColumns:true,
				rownumbers:true,
				remoteSort:false,
				scrollbarSize:0,
				singleSelect:true,
				columns:[[
				      {title:"脱机充值序号",field:"dealNo",sortable:true,width:parseInt($(this).width()*0.2)},
				      {title:"交易金额",field:"dealAmt",sortable:true,width:parseInt($(this).width()*0.2)},
				      {title:"交易类型",field:"dealType",sortable:true,width:parseInt($(this).width()*0.2)},
				      {title:"终端机编号",field:"dealEndno",sortable:true,width:parseInt($(this).width()*0.2)},
				      {title:"交易日期",field:"dealDate",sortable:true,width:parseInt($(this).width()*0.2)}
				]],
				data:[]
			});
			comsumeinfo = $("#consumeinfo").datagrid({
				border:false,
				striped:true,
				//height:26*11,
				fit:true,
				fitColumns:true,
				remoteSort:false,
				rownumbers:true,
				scrollbarSize:0,
				singleSelect:true,
				columns:[[
				      {title:"脱机消费序号",field:"dealNo",sortable:true,width:parseInt($(this).width()*0.2)},
				      {title:"交易金额",field:"dealAmt",sortable:true,width:parseInt($(this).width()*0.2)},
				      {title:"交易类型",field:"dealType",sortable:true,width:parseInt($(this).width()*0.2)},
				      {title:"终端机编号",field:"dealEndno",sortable:true,width:parseInt($(this).width()*0.2)},
				      {title:"交易日期",field:"dealDate",sortable:true,width:parseInt($(this).width()*0.2)}
				]],
				data:[]
			});
		});
		function executeGetCardInfo(){
			$.messager.progress({text : '正在验证卡信息,请稍后...'});
			setTimeout("readCard()",1000);
		}
		function readCard(){
			cardinfo = getcardinfo();
			if(dealNull(cardinfo['card_No']).length == 0 || dealNull(cardinfo['errMsg']).length > 0){
				$.messager.progress('close');
				$.messager.alert('系统消息','读卡出现错误，请重新放置好卡片，再次进行读取！' + cardinfo["errMsg"],'error',function(){
					window.history.go(0);
				});
				return false;
			}
			$('#fkfbs').val(cardinfo['fkfbs']);
			if(cardinfo['use_Flag'] == "00"){
				$('#use_Flag').val("未启用");
			}else if(cardinfo['use_Flag'] == "01"){
				$('#use_Flag').val("启用");
			}else{
				$('#use_Flag').val("未知");
			}
			
			$('#card_Valid_Date').val(cardinfo['card_Valid_Date'].substring(0,4) + "-" + cardinfo['card_Valid_Date'].substring(4,6) + "-" + cardinfo['card_Valid_Date'].substring(6,8));
			$('#name').val(cardinfo['name']);
			if(cardinfo['sex'] == "1"){
				$("#csex").val("男");
			}else if(cardinfo['sex'] == "2"){
				$("#csex").val("女");
			}else{
				$("#csex").val("未说明");
			}
			$('#certNo').val(cardinfo['cert_No']);
			if(cardinfo['cert_Type'] == "01"){
				$('#cert_Type').val("身份证");
			}else if(cardinfo['cert_Type'] == "02"){
				$('#cert_Type').val("户口博");
			}else if(cardinfo['cert_Type'] == "03"){
				$('#cert_Type').val("军官证");
			}else if(cardinfo['cert_Type'] == "04"){
				$('#cert_Type').val("护照");
			}else if(cardinfo['cert_Type'] == "05"){
				$('#cert_Type').val("户籍证明");
			}else{
				$('#cert_Type').val("其他");
			}
			$('#cardNo').val(cardinfo['card_No']);
			$("#cardAmt").val((parseFloat(isNaN(cardinfo['wallet_Amt']) ? 0:cardinfo['wallet_Amt'])/100).toFixed(2));
			$('#busType').val(cardinfo['busTypeName']);
			$('#start_Date').val(cardinfo['start_Date'].substring(0,4) + "-" + cardinfo['start_Date'].substring(4,6) + "-" + cardinfo['start_Date'].substring(6,8));
			$('#valid_Date').val(cardinfo['valid_Date'].substring(0,4) + "-" + cardinfo['valid_Date'].substring(4,6) + "-" + cardinfo['valid_Date'].substring(6,8));
			$('#use_Version').val(cardinfo['use_Version']);
			$('#indus_Code').val(cardinfo['indus_Code']);
			$('#recharge_Tr_Count').val(cardinfo["recharge_Tr_Count"]);//充值序列号
			$('#consume_Tr_Count').val(cardinfo["consume_Tr_Count"]);//消费序列号
			validCard();
			//读取充值明细
			deteteGridAllRows("rechargeinfo");
			var isSuc = getcardrechargeinfo();
			if(isSuc > 0){
				var counts = (isSuc.length)/43;
				for(var i = 1;i<= counts;i++){
					var onerow = isSuc.substring(43 * (i - 1),43 * i);
					var time = onerow.substring(29,43);
					var rtype = "";
					var type = onerow.substring(15,17);
					if(type == "02"){
						rtype = "充值";
					}else if(type == "06"){
						rtype = "普通消费";
					}else if(type == "09"){
						rtype = "复合消费";
					}
					time = time.substring(0,4) + "-" + time.substring(4,6) + "-" + time.substring(6,8) + " " + time.substring(8,10) + ":" + time.substring(10,12) + ":" + time.substring(12,14);
					$("#rechargeinfo").datagrid("appendRow",{
						dealNo:onerow.substring(0,5),
						dealAmt:Number(onerow.substring(5,15)).div100(),
						dealType:rtype,
						dealEndno:onerow.substring(17,29),
						dealDate:time
					});
				}
			}
			isSuc = -1;
			//读取消费明细
			deteteGridAllRows("consumeinfo");
			isSuc = getcardconsumeinfo();
			if(isSuc > 0){
				var counts = (isSuc.length)/43;
				for(var i = 1;i<= counts;i++){
					var onerow = isSuc.substring(43 * (i - 1),43 * i);
					var time = onerow.substring(29,43);
					var rtype = "";
					var type = onerow.substring(15,17);
					if(type == "02"){
						rtype = "充值";
					}else if(type == "06"){
						rtype = "普通消费";
					}else if(type == "09"){
						rtype = "复合消费";
					}
					time = time.substring(0,4) + "-" + time.substring(4,6) + "-" + time.substring(6,8) + " " + time.substring(8,10) + ":" + time.substring(10,12) + ":" + time.substring(12,14);
					$("#consumeinfo").datagrid("appendRow",{
						dealNo:onerow.substring(0,5),
						dealAmt:Number(onerow.substring(5,15)).div100(),
						dealType:rtype,
						dealEndno:onerow.substring(17,29),
						dealDate:time
					});
				}
			}
			$.messager.progress('close');
		}
		//验证卡信息
		function validCard(){
			$.post('cardService/cardServiceAction!getCardAndPersonInfo.action',"cardNo=" + $('#cardNo').val(),function(data,status){
				if(status == 'success'){
					$('#cardState').val(data.card.note);
					$('#cardType').val(data.card.cardTypeStr);
					if(dealNull(data.card.cardNo).length == 0){
						$.messager.progress('close');
						$.messager.alert('系统消息','验证卡片错误，该卡在系统中不存在！','error');
					}
				}else{
					$.messager.progress('close');
					$.messager.alert('系统消息','验证卡信息时出现错误，请重试...','error',function(){
						window.history.go(0);
					});
				}
			},'json');
		}
	</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 			<div class="well well-small datagrid-toolbar">
			<span class="badge">提示</span>
			<span>在此你可以对<span class="label-info"><strong>卡片进行卡内信息查询操作！<span style="color:red;">注意：</span>由于钱包账户是脱机消费，卡片消费信息没有实时上传进行账户扣款，因此卡内钱包余额信息可能不等于后台钱包账户信息。</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',border:false,fit:true" style="margin:0px;width:auto;border-left:none;">
		<div class="easyui-layout" style="width:100%;padding:0px 0px;" data-options="fit:true,border:false">
			<div  data-options="region:'north',border:false" style="overflow:hidden;border-bottom:none;border-left:none;">
				<div id="tb"  style="margin:0px;padding:0px;" class="datagrid-toolbar">
					<table cellpadding="0" cellspacing="0" style="width:100%;margin:0px 0px 5px 0px;">
						<tr>
							<td width="12%" align="right" class="label_left">发卡方代码：</td>
							<td align="left" class="label_right"><input name="fkfbs" class="textinput easyui-validatebox" id="fkfbs" type="text" readonly="readonly" disabled="disabled"/></td>
							<td align="right" class="label_left">启用标识：</td>
							<td class="label_right"><input id="use_Flag" type="text" class="textinput" name="use_Flag" readonly="readonly" disabled="disabled"/></td>
							<td align="right" class="label_left">卡片发放日期：</td>
							<td class="label_right">
								<input id="card_Valid_Date" type="text" class="textinput" name="card_Valid_Date" readonly="readonly" disabled="disabled"/>
								<shiro:hasPermission name="cardinfoinnerquery">
									<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0)" class="easyui-linkbutton"  id="readcard" name="readcard"  onclick="executeGetCardInfo()">读卡</a>
								</shiro:hasPermission>
							</td>
						</tr>
						<tr>
							<td align="right" class="label_left">姓名：</td>
							<td class="label_right"><input name="name"  class="textinput" id="name" type="text" readonly="readonly" disabled="disabled"/></td>
							<td align="right" class="label_left">性别：</td>
							<td class="label_right"><input name="csex"  class="textinput" id="csex" type="text" readonly="readonly" disabled="disabled"/></td>
							<td align="right" class="label_left">证件号码：</td>
							<td class="label_right"><input name="certNo"  class="textinput" id="certNo" type="text" readonly="readonly" disabled="disabled"/></td>
						</tr>
						<tr>
							<td align="right" class="label_left">证件类型：</td>
							<td class="label_right" colspan="1"><input id="cert_Type" type="text" class="textinput" name="cert_Type" readonly="readonly" disabled="disabled"/></td>
							<td width="10%" align="right" class="label_left">卡号：</td>
							<td align="left" class="label_right"><input name="cardNo" class="textinput easyui-validatebox" id="cardNo" type="text" readonly="readonly" disabled="disabled"/></td>
							<td align="right" class="label_left">卡内余额：</td>
							<td><input name="cardAmt" class="textinput easyui-validatebox" id="cardAmt" type="text" readonly="readonly" disabled="disabled"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
						</tr>
						<tr>
							<td align="right" class="label_left">卡状态：</td>
							<td class="label_right"><input id="cardState" type="text" class="textinput" name="cardState"  readonly="readonly" disabled="disabled"/></td>
							<td align="right" class="label_left">卡类型：</td>
							<td class="label_right"><input id="cardType" type="text" class="textinput" name="cardType" readonly="readonly" disabled="disabled"/></td>
							<td align="right" class="label_left">公交类型：</td>
							<td class="label_right" colspan="1"><input id="busType" type="text" class="textinput" name="busType" readonly="readonly" disabled="disabled"/></td>
						</tr>
						<tr>
							<td align="right" class="label_left">应用启用日期：</td>
							<td class="label_right" colspan="1"><input id="start_Date" type="text" class="textinput" name="start_Date"  readonly="readonly" disabled="disabled"/></td>
							<td align="right" class="label_left">应用有效期：</td>
							<td class="label_right"><input id="valid_Date" type="text" class="textinput" name="valid_Date" readonly="readonly" disabled="disabled"/></td>
							<td align="right" class="label_left">应用版本：</td>
							<td class="label_right" colspan="1"><input id="use_Version" type="text" class="textinput" name="use_Version"  readonly="readonly" disabled="disabled"/></td>
						</tr>
						<tr>
							<td align="right" class="label_left">行业代码：</td>
							<td class="label_right"><input id="indus_Code" type="text" class="textinput" name="indus_Code" readonly="readonly" disabled="disabled"/></td>
							<td align="right" class="label_left">充值计数器：</td>
							<td class="label_right"><input id="recharge_Tr_Count" type="text" class="textinput" name="recharge_Tr_Count" readonly="readonly" disabled="disabled"/></td>
							<td align="right" class="label_left">消费计数器：</td>
							<td class="label_right"><input id="consume_Tr_Count" type="text" class="textinput" name="consume_Tr_Count" readonly="readonly" disabled="disabled"/></td>
						</tr>
					</table>
				</div>
			</div>
			<div data-options="region:'center',fit:true,border:false">
				<div class="easyui-tabs" data-options="fit:true,border:false,pill:true" >
					<div title="最近10条充值记录" style="padding:0px">
						<table id="rechargeinfo" title=""></table>
					</div>
					<div title="最近10条消费记录" style="padding:0px">
						<table id="consumeinfo" title=""></table>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>