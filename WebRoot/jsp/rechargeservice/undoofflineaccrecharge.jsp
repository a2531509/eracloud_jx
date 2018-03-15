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
    <title>${ACC_KIND_NAME_QB }充值撤销</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;
	var finalcyclenum = 2;
	var $grid;
	var cardinfo;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		 $grid = createDataGrid({
		 	id:"dg",
		 	url:"recharge/rechargeAction!offlineAccRechargeQuery.action",
		 	scrollbarSize:0,
		 	frozenColumns:[[
				{field:'V_V',title:'',sortable:true,checkbox:true},
				{field:'DEAL_NO',title:'流水号',sortable:true,width:parseInt($(this).width() * 0.05)},
				{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width() * 0.08)},
				{field:'ACC_NAME',title:'姓名',sortable:true,width:parseInt($(this).width() * 0.06)},
				{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width() * 0.15),fixed:true},
				{field:'CARDTYPE',title:'卡类型',sortable:true,width:parseInt($(this).width() * 0.06)} 
			]],
		 	columns:[[
	        	{field:'ACC_NO',title:'账户号',sortable:true,width:parseInt($(this).width() * 0.05)},
	        	{field:'ACCKIND',title:'账户类型',sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:'ACCBAL',title:'充值前账户余额',sortable:true,align:'right',width:parseInt($(this).width() * 0.08)},
	        	{field:'AMT',title:'充值金额',sortable:true,align:'right',width:parseInt($(this).width() * 0.06)},
	        	{field:'DEALDATE',title:'充值日期',sortable:true,width:parseInt($(this).width() * 0.12)},
	        	{field:'DEALSTATE',title:'记录状态',sortable:true},
	        	{field:'CLR_DATE',title:'清分日期',sortable:true},
	        	{field:'FULL_NAME',title:'网点',sortable:true},
	        	{field:'NAME',title:'柜员',sortable:true}
		    ]]
		 });
		 zhuguan("zgOperId");
	     var pager = $grid.datagrid("getPager");
		 pager.pagination({
		     buttons:$("#zhuguanPwdDiv")
		 });
	});
	function readCard(){
		try{
			$.messager.progress({text : '正在验证卡信息,请稍后...'});
			cardinfo = getcardinfo();
			if(dealNull(cardinfo['card_No']).length == 0){
				$.messager.progress('close');
				$.messager.alert('系统消息','读卡出现错误，请拿起并重新放置好卡片，再次进行读取！' + cardinfo["errMsg"],'error');
				return;
			}
			$('#cardNo').val(cardinfo['card_No']);
			$('#cardAmt').val((parseFloat(isNaN(cardinfo["wallet_Amt"]) ? 0 : cardinfo["wallet_Amt"])/100).toFixed(2));
			$('#cardTrCount').val(cardinfo["consume_Tr_Count"]);//消费序列号
			validCard();
		}catch(e){
			errorsMsg = "";
			for (i in e) {
				errorsMsg += i + ":" + eval("e." + i) + "\n";
			}
			$.messager.alert('系统消息',errorsMsg,'error');
		}
	}
	function validCard(){
		$.post("cardService/cardServiceAction!getCardAndPersonInfo.action","cardNo=" + $("#cardNo").val(),function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				if(dealNull(data.card.cardNo).length == 0){
					$.messager.alert("系统消息","验证卡片信息发生错误：卡号信息不存在，该卡不能进行操作！","error",function(){
						window.history.go(0);
					});
				}
				$("#cardStateHidden").val(data.card.cardState);
				query();
			}else{
				$.messager.alert("系统消息","验证卡片信息发生错误，请重试...","error",function(){
					window.history.go(0);
				});
			}
		},"json").error(function(){
			$.messager.alert("系统消息","验证卡片信息发生错误，请重试...","error",function(){
				window.history.go(0);
			});
		});
	}
	function query(){
		if($("#cardNo").val().replace(/\s/g,'') == ''){
			$.messager.alert("系统消息","请输入查询卡号！","error");
			return;
		}
		$grid.datagrid('load',{
			queryType:'0',
			cardNo:$('#cardNo').val()
		});
	}
	function saveCancelFirst(){
		var temprow = $grid.datagrid('getSelected');
		if(temprow){
			if($("#cardStateHidden").val() != "1"){
				$.messager.alert("系统消息","卡状态不正常不能进行充值撤销！","error");
				return;
			}
			$.messager.confirm('系统消息','您确定要撤销卡号为【' + temprow.CARD_NO + '】，流水号=' + temprow.DEAL_NO + '的${ACC_KIND_NAME_QB }充值记录吗？',function(is){
				if(is){
					$.messager.progress({text : '正在进行撤销,请稍后...'});
					$.post('recharge/rechargeAction!saveOfflineAccRechargeCancel.action',
					    {
							card_Recharge_TrCount:$('#cardTrCount').val(),
							dealNo:temprow.DEAL_NO,
							cardAmt:$('#cardAmt').val(),
							zgOperId:$("#zgOperId").combobox("getValue"),
							pwd:$("#pwd").val()
						},
					    function(data,status){
							if(status == 'success'){
								if(data.status != '0'){
									$.messager.progress('close');
									$.messager.alert('系统消息',data.msg,'error');
								}else if(data.status == '0'){
									$('#dealNo').val(data.dealNo);
									writeCard(data.writecarddata);
								}
							}else{
								$.messager.alert(',系统消息','${ACC_KIND_NAME_QB }充值撤销出现错误，请重试！','error');
							}
					},'json').error(function(){
						$.messager.alert(',系统消息','${ACC_KIND_NAME_QB }充值撤销出现错误，请重试！','error');
					});
				}
			});
		}else{
			$.messager.alert("系统消息","${ACC_KIND_NAME_QB }充值撤销，请选择一条充值待撤销记录！","error");
			return;
		}
	}
	function writeCard(writecarddata){
		cardinfo = getcardinfo();
		if(judgeReadCardOk(cardinfo)){
			cycleNum0 = 0;
			writecard_onlydecrease($('#cardNo').val(),writecarddata);
			cardinfo = getcardinfo();
			if(judgeReadCardOk(cardinfo)){
				if(Number((isNaN(cardinfo["wallet_Amt"]) ? -1 : cardinfo["wallet_Amt"])) != Number($('#cardAmt').val()).mul100()){
					saveConfrim();
				}else if(Number((isNaN(cardinfo["wallet_Amt"]) ? -1 : cardinfo["wallet_Amt"])) == Number($('#cardAmt').val()).mul100()){
					cycleNum1++;
					if(cycleNum1 >= finalcyclenum){
						saveCancel();
					}else{
						$.messager.progress('close');
						$.messager.alert('系统消息','${ACC_KIND_NAME_QB }充值撤销写卡出现错误，请拿起并重新放置好卡片，点击【确定】再次进行撤销！','error',function(){
							$.messager.progress({text : '正在进行撤销，请稍后....'});
							writeCard(writecarddata);
						});
					}
				}
			}else{
				write_card_next(writecarddata);
			}
		}else{
			cycleNum0++;
			if(cycleNum0 >= finalcyclenum){
				saveCancel();
			}else{
				$.messager.progress('close');
				$.messager.alert('系统消息','写卡前获取卡片信息出现错误，请拿起并重新放置好卡片，点击【确定】再次进行撤销！'  ,'error',function(){
					$.messager.progress({text : '正在进行撤销，请稍后....'});
					writeCard(writecarddata);
				});
			}
		}
	}
	function write_card_next(writecarddata){
		cardinfo = getcardinfo();
		if(judgeReadCardOk(cardinfo)){
			cycleNum2 = 0;
			if(Number((isNaN(cardinfo["wallet_Amt"]) ? -1 : cardinfo["wallet_Amt"])) != Number($('#cardAmt').val()).mul100()){
				saveConfrim();
			}else if(Number((isNaN(cardinfo["wallet_Amt"]) ? -1 : cardinfo["wallet_Amt"])) == Number($('#cardAmt').val()).mul100()){
				cycleNum1++;
				if(cycleNum1 >= finalcyclenum){
					saveCancel();
				}else{
					$.messager.progress('close');
					$.messager.alert('系统消息','${ACC_KIND_NAME_QB }充值撤销写卡出现错误，请拿起并重新放置好卡片，点击【确定】再次进行撤销！','error',function(){
						$.messager.progress({text : '正在进行撤销，请稍后....'});
						writeCard(writecarddata);
					});
				}
			}
		}else{
			cycleNum2++;
			if(cycleNum2 >= finalcyclenum){
				$.messager.progress('close');
				$.messager.alert('系统消息','写卡后获取卡片信息出现错误，请再次读卡确认是否撤销成功，并处理【灰记录】！','error',function(){
					$.messager.progress({text : '正在加载，请稍后....'});
					window.history.go(0);
				});
			}else{
				$.messager.progress('close');
				$.messager.alert('系统消息','写卡后获取卡片信息出现错误，请拿起并重新放置好卡片，点击【确定】再次进行撤销！','error',function(){
					$.messager.progress({text : '正在进行撤销，请稍后....'});
					write_card_next(writecarddata);
				});
			}
		}
	}
	function saveConfrim(){
		$.post('recharge/rechargeAction!saveOfflineAccRechargeCancelConfirm.action',{dealNo:$('#dealNo').val()},function(data,status){
			$.messager.progress('close');
			if(status == 'success'){
				if(data.status == '0'){
					showReport("${ACC_KIND_NAME_QB }充值撤销",$('#dealNo').val(),function(){
						window.history.go(0);
					});
				}else{
					$.messager.alert('系统消息','写卡成功，确认撤销灰记录出现错误：' + data.msg + '，请在打印凭证后人工确认【灰记录】！','error',function(){
						showReport("${ACC_KIND_NAME_QB }充值撤销",$('#dealNo').val(),function(){
							window.history.go(0);
						});
					});
				}
			}else{
				$.messager.alert('系统消息','写卡成功，确认撤销灰记录出现错误，请在打印凭证后人工确认【灰记录】！','error',function(){
					showReport("${ACC_KIND_NAME_QB }充值撤销",$('#dealNo').val(),function(){
						window.history.go(0);
					});
				});
			}		
		},'json').error(function(){
			$.messager.progress('close');
			if($("#dealNo").val() != ""){
				$.messager.alert('系统消息','写卡成功，确认撤销灰记录出现错误，请在打印凭证后人工确认【灰记录】！','error',function(){
					showReport("${ACC_KIND_NAME_QB }充值撤销",$('#dealNo').val(),function(){
						window.history.go(0);
					});
				});
			}else{
				$.messager.alert('系统消息','写卡成功，确认撤销灰记录出现错误，请人工确认【灰记录】！','error',function(){
					$.messager.progress({text : '正在进行加载，请稍后....'});
					window.location.href = window.location.href + "?mm_=" + Math.random();
				});
			}
		});
	}
	function saveCancel(){
		$.post('recharge/rechargeAction!saveOfflineAccRechargeCancelCz.action',{dealNo:$('#dealNo').val()},function(data,status){
			$.messager.progress('close');
			if(status == 'success'){
				if(data.status == '0'){
					$.messager.alert('系统消息','充值撤销出现错误，请重新进行撤销！','error',function(){
						$.messager.progress({text : '正在加载，请稍后....'});
						window.history.go(0);
					});
				}else{
					$.messager.alert('系统消息','充值撤销出现错误，冲正出现错误，' + data.msg + '请人工取消【灰记录】！','error',function(){
						$.messager.progress({text:'正在进行加载，请稍后....'});
						window.history.go(0);
					});
				}
			}else{
				$.messager.alert('系统消息','充值撤销出现错误，冲正出现错误，请人工取消【灰记录】！','error',function(){
					$.messager.progress({text:'正在加载，请稍后....'});
					window.history.go(0);
				});
			}
		},'json').error(function(){
			$.messager.alert('系统消息','充值撤销出现错误，冲正出现错误，请人工取消【灰记录】！','error',function(){
				$.messager.progress({text:'正在加载，请稍后....'});
				window.history.go(0);
			});
		});
	}
	function judgeReadCardOk(obj){
		if(!obj){
			return false;
		}
		if(obj['card_No'] == ''){
			return false;
		}
		if(obj['card_No'] == undefined){
			return false;
		}
		if(typeof(obj['card_No']) == 'undefined'){
			return false;
		}
		if(obj['card_No'] == 'undefined'){
			return false;
		}
		if(obj['card_No'] != $('#cardNo').val()){
			return false;
		}
		return true;
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
    <input type="hidden" name="cardTrCount" id="cardTrCount">
    <input type="hidden" name="dealNo" id="dealNo">
    <input type="hidden" name="cardStateHidden" id="cardStateHidden">
 	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>${ACC_KIND_NAME_QB }充值记录进行</strong></span><span class="label-info">撤销操作！<span style="color:red;font-weight:600">注意：</span>只有当日且充值成功的记录才能进行${ACC_KIND_NAME_QB }充值撤销，如有灰记录则应先进行灰记录处理！</span></span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="height:50px;margin:0px;width:auto;border-left:none;border-bottom:none;">
	  	<div id="tb" style="padding:2px 0">
			<table style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft">卡号：</td>
					<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" readonly="readonly"/></td>
					<td class="tableleft">卡内余额：</td>
					<td class="tableright"><input name="cardAmt"  class="textinput" id="cardAmt" type="text" readonly="readonly"/></td>
					<td style="padding-left:2px">
						<shiro:hasPermission name="onlinerechargecanelreadcard">
							<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton"  id="readcard" name="readcard"  onclick="readCard()">读卡</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="onlinerechargecanelquery">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="onlinerechargecanelsave">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-cancel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="saveCancelFirst()">确定撤销</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
 		<table id="dg" title="【当前柜员】钱包充值记录"></table>
 		<div id="zhuguanPwdDiv">
 			<table>
	  			<tr> 
	  				<td width="150px" align="right">授权柜员：</td>
	  				<td><input type="text" class="textinput" name="zgOperId" id="zgOperId" /></td>
	  				<td align="right">密码：</td>
	  				<td><input type="password" class="textinput" name="pwd" id="pwd" maxlength="6"/></td>
	  			</tr>
 			</table>
 		</div>
	</div>
</body>
</html>