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
    <title>账户返还</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $dg;
	var $temp;
	var $grid;
	var $cardinfo;
	var cardmsg;
	function calFee(){
		var tempFee = 0;
		var curcard = $("#cardinfo").datagrid('getSelected');
		if(!curcard || curcard.REDEEM_FLAG != '是'){
			document.getElementById("totalAmt").value = "0";
			return;
		}
		var allacc = accinfo.window.getAllData();
		if(allacc && allacc.length > 0){
			for(var i = 0;i < allacc.length;i++){
				if(allacc[i].ACC_KIND == '01' && allacc[i].BAL_RSLT_FLAG == "0") { // 如果是钱包账户
					if(curcard.RSV_ONE_FLAG == "0") { // 好卡
						tempFee = (Number(parseFloat(tempFee).toFixed(1)) + Number(parseFloat(curcard.PRV_BAL.replace(/,/g,"")).toFixed(1)));
					} else if(curcard.RSV_ONE_FLAG == "1") { // 坏卡
						var curdate = getDatabaseDate();
						if(curdate < (allacc[0]).FHRQ){ // 未到返还日期
							tempFee = 0;
							jAlert("坏卡未到返还日期.", "warning");
							return;
						} else { // 已到返还日期
							tempFee = (Number(parseFloat(tempFee).toFixed(1)) + Number(parseFloat(allacc[i].AVAILABLEAMT.replace(/,/g,"")).toFixed(1)));
						}
					} else if(curcard.RSV_ONE_FLAG == '2'){ // 无卡
						// do nothing, 钱包不返还
					}
				} else { // 非钱包账户（联机账户）
					tempFee = parseFloat(tempFee) + parseFloat(allacc[i].AVAILABLEAMT.replace(/,/g,""));
				}
			}
		}
		document.getElementById("totalAmt").value = Math.abs(parseFloat(tempFee)).toFixed(2);
	}
	$(function(){
		addNumberValidById("bankCardNo");
		
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createSysCode({id:"agtCertType",codeType:"CERT_TYPE",value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"});
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no",
			//minLength:"1"
		});
		$cardinfo = $("#cardinfo");
		$cardinfo.datagrid({
			url:"cardService/cardServiceAction!returnCashQuery.action",
			fit:true,
			pagination:false,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			checkOnSelect:true,
			scrollbarSize:0,
			fitColumns:true,
			columns:[[
				{field:'V_V',checkbox:true},
	        	{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:'CERT_TYPE',title:'证件类型',sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width() * 0.14)},
	        	{field:'CARD_TYPE',title:'卡类型',sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width() * 0.15)},
	        	{field:'CARDSTATE',title:'卡状态',sortable:true,width:parseInt($(this).width() * 0.05)},
	        	{field:'BUSTYPE',title:'公交类型',sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:'REDEEM_FLAG',title:'是否返还余额',sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:'RSV_ONE',title:'余额返还方式',sortable:false},
	        	{field:'PRV_BAL',title:'卡面余额',sortable:false}
	        ]],
		 	toolbar:'#tb',
            onLoadSuccess:function(data){
	           	 if(data.status != 0){
	           		 $.messager.alert('系统消息',data.errMsg,'error');
	           	 }
	           	 if(data.rows.length > 0 ){
		           	 $(this).datagrid('selectRow',0);
	           	 }
	           	$("#form").form("reset");
            },
            onSelect:function(index,data){
            	if(data == null)return;
	            $("#accinfo").get(0).src =  "jsp/cardService/inneraccinfo.jsp?noAccKind=03&bal_rslt=true&fhrq=true&cardNo=" + data.CARD_NO;
	            if($("#accinfodiv").css("display") != "block"){
		            $("#accinfodiv").show();
	            }
            }
		 });		
	});
	function query(){
		if($("#certNo").val().replace(/\s/g,'') == '' && $("#cardNo").val().replace(/\s/g,'') == ''){
			$.messager.alert('系统消息','请输入查询证件号码或卡号！','error');
			return;
		}
		$('#totalAmt').val('0');//总金额设置为0
		//清空账户表格
		if($("#accinfodiv").css("display") == "block"){
			accinfo.window.deleteAllData();
		}
		$("input[type=checkbox]").each(function(){
			this.checked = false;
		});
		$cardinfo.datagrid('load',{
			queryType:'0',//查询类型
			certNo:$('#certNo').val(),
			cardNo:$('#cardNo').val()
		});
	}
	function readCard(){
		$.messager.progress({text:'正在获取卡片信息，请稍后....'});
		cardmsg = getcardinfo();
		if(dealNull(cardmsg["card_No"]).length == 0){
			$.messager.progress('close');
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
			return;
		}
		$.messager.progress('close');
		$('#cardNo').val(cardmsg["card_No"]);
		$("#cardAmt").val((parseFloat(isNaN(cardmsg['wallet_Amt']) ? 0:cardmsg['wallet_Amt'])/100).toFixed(2));
		query();
	}
	function readIdCard(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#certType").combobox("setValue",'1');
		$("#certNo").val(certinfo["cert_No"]);
		query();
	}
	function readIdCard2(){
		$.messager.progress({text:'正在获取证件信息，请稍后....'});
		var certinfo = getcertinfo();
		if(dealNull(certinfo["cert_No"]).length < 15){			
			$.messager.progress('close');
			return;
		}
		$.messager.progress('close');
		$("#agtCertType").combobox("setValue",'1');
		$("#agtCertNo").val(certinfo["cert_No"]);
		$("#agtName").val(certinfo["name"]);
	}
	function readSMK2(){
		$.messager.progress({text:"正在获取证件信息，请稍后...."});
		var queryCertInfo = getcardinfo();
		if(dealNull(queryCertInfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + queryCertInfo["errMsg"],"error");
			$.messager.progress('close');
			return;
		}
		$.messager.progress("close");
		$("#agtCertType").combobox("setValue","1");
		$("#agtCertNo").val(dealNull(queryCertInfo["cert_No"]));
		$("#agtName").val(dealNull(queryCertInfo["name"]));
	}
	//注销保存
	function zx(){
		var curcard =  $cardinfo.datagrid('getSelected');
		if(curcard){
			if(curcard.REDEEM_FLAG != '是'){
				$.messager.alert("系统消息","选择的卡类型当前不允许账户返还操作！","error");
				return;
			}
			if(curcard.CARD_STATE != '9'){
				$.messager.alert("系统消息","该卡不是注销状态，不能进行账户返还操作！","error");
				return;
			}
			if(curcard.RSV_ONE_FLAG != '0' && curcard.RSV_ONE_FLAG != '1' && curcard.RSV_ONE_FLAG != '2'){
				$.messager.alert("系统消息","该卡不存在注销或补换卡记录信息，不能进行账户返还","error");
				return;
			}
			var allacc = accinfo.window.getAllData()
			if(!allacc || allacc.length < 1){
				$.messager.alert("系统消息","账户信息不存在，请仔细核对后，稍后重试！","error");
				return;
			}
			if((allacc[0]).BAL_RSLT_FLAG != "0"){
				$.messager.alert("系统消息","账户余额已返还不能重复进行返还！","error");
				return;
			}
			var bankCardNo = $('#bankCardNo').val();
			if(!bankCardNo){
				jAlert("银行卡号为空.", "warning");
				return;
			}
			var curdate = getDatabaseDate();
			if(curcard.RSV_ONE_FLAG == '1'){ // 坏卡
				if(curdate < (allacc[0]).FHRQ){ // 未到返还日期
					jAlert("坏卡未到返还日期.", "warning");
					return;
				}
			}
			
			$.messager.progress({text : '数据处理中，请稍后....'});
			$.post('cardService/cardServiceAction!saveReturnCash.action',$('form').serialize()+ "&cardNo=" + curcard.CARD_NO + "&cardAmt=" + (allacc[0]).FHRQ,function(data,status){
				$.messager.progress('close');
				if(status == 'success'){
					if(data.status == "0"){
						$.messager.alert('系统消息',"余额返现登记成功",(data.status == 0 ? 'info' : 'error'),function(){
							if(data.status == '0'){
								showReport("余额返现登记",data.dealNo,function(){
									window.history.go(0);
								});
							}
						});
					}else{
						$.messager.alert('系统消息',data.msg,(data.status == 0 ? 'info' : 'warning'),function(){
							if(data.status == '0'){
								showReport("余额返现登记",data.dealNo,function(){
									window.history.go(0);
								});
							}
						});
					}
				}else{
					$.messager.alert('系统消息','请求出现错误，请稍后重试！','error');
				}
			},'json');
		}else{
			$.messager.alert("系统消息","请选择一条卡信息记录！",'warning');
		}
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 		<div class="well well-small datagrid-toolbar">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>卡片进行余额返现登记还操作！</strong><span style="color:red;font-weight:600;">注意：</span>只有注销卡才能进行余额返现登记操作</span></span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="height:50px;margin:0px;width:auto;border-bottom:none;border-left:none;">
	  	<div id="tb" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" class="tablegrid">
				<tr>
					<tr>
						<!--  
							<td style="padding-left:2px">证件类型：</td>
							<td style="padding-left:2px"><input id="certType" type="text" class="easyui-combobox  easyui-validatebox" name="certType" value="1" style="width:174px;cursor:pointer;"/></td>
						-->
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text" /></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" /></td>
						<td class="tableleft">卡余额：</td>
						<td class="tableright"><input id="cardAmt" type="text" class="textinput" name="cardAmt" style="width:174px;" readonly="readonly"/></td>
						<td class="tableright" colspan="4">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<!-- <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a> -->
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-ok'" href="javascript:void(0);" class="easyui-linkbutton" onclick="zx()">确定</a>
						</td>
				</tr>
			</table>
		</div>
  		<table id="cardinfo" title="卡信息" style="height:150px;"></table>
	</div>
	<div data-options="region:'south',split:false,border:true" style="height:300px; width:auto;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
		<div style="width:100%;display:none;" id="accinfodiv" class="datagrid-toolbar">
  			<h3 class="subtitle">账户信息</h3>
  			<iframe name="accinfo" id="accinfo"  width="100%" frameborder="0" height="84"></iframe>
		</div>
		<div style="width:100%;height:100%">
			<form id="form" method="post" class="datagrid-toolbar" style="width:100%;height:100%">
				 <h3 class="subtitle">代理人信息</h3>
				 <table class="tablegrid" style="width:100%;">
					 <tr>
						<th class="tableleft">返还总金额：</th>
						<td class="tableright"><input name="totalAmt" id="totalAmt" value="0" class="textinput easyui-validatebox" type="text" required="required" readonly="readonly"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
						<td class="tableleft">银行卡号：</td>
						<td class="tableright"><input name="bankCardNo"  class="textinput" id="bankCardNo" type="text" maxlength="19"/></td>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright"><input id="agtCertType" type="text" class="easyui-combobox  easyui-validatebox" name="rec.agtCertType" value="1" style="width:174px;"/> </td>
					</tr>
					<tr>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright"><input name="rec.agtCertNo"  class="textinput easyui-validatebox" id="agtCertNo" type="text"  maxlength="18" validtype="idcard" /></td>
						<th class="tableleft">代理人姓名：</th>
						<td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput easyui-validatebox"   maxlength="30" /></td>
					 	<th class="tableleft">代理人联系电话：</th>
						<td class="tableright">
							<input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox"  maxlength="11"  validtype="mobile"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a></td>
					</tr>
			   </table>
		    </form>	
	    </div>		
   </div>
</body>
</html>