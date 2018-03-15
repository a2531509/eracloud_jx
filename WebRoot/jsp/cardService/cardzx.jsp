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
    <title>卡片注销</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $temp;
	var $grid;
	var $cardinfo;
	var cardmsg;
	var isreadcard = 1;
	var isquery = 1;
	var curreadcardno = "";
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createSysCode({id:"agtCertType",codeType:"CERT_TYPE",value:"<%=com.erp.util.Constants.CERT_TYPE_SFZ%>"});
		$("#isGoodCard").combobox({
			width:174,
			valueField:'codeValue',
			editable:false,
		    textField:'codeName',
		    panelHeight: 'auto',
		    data:[{codeValue:'0',codeName:'好卡'},{codeValue:'1',codeName:'坏卡'},{codeValue:'2',codeName:'无卡'}],
		    onSelect:function(node){
		 		if(node.codeValue == '0'){
		 			$.messager.alert("系统消息","已选择是好卡，请先进行读卡,在进行查询！","warning");
		 		}
		 		$(this).combobox('setValue',node.codeValue);
				$("#isGoodCard").val(node.codeValue);
				isreadcard = 1;
				isquery = 1;
				curreadcardno = "";
		 	}
		 });
		createSysCode({id:"zxreason",codeType:"CANCEL_REASON"});
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no"
			//minLength:"1"
		});
		 $cardinfo = $("#cardinfo");
		 $cardinfo.datagrid({
			url:"cardService/cardServiceAction!toZxquery.action",
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
	        	{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width() * 0.12)},
	        	{field:'CARD_TYPE',title:'卡类型',sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width() * 0.15)},
	        	{field:'CARD_STATE',title:'卡状态',sortable:true,width:parseInt($(this).width() * 0.08)},
	        	{field:'BUS_TYPE',title:'公交类型',sortable:true,width:parseInt($(this).width() * 0.06)},
	        	{field:'REDEEM_FLAG',title:'是否可注销',sortable:true,width:parseInt($(this).width() * 0.06)}
	        ]],
		 	toolbar:'#tb',
            onLoadSuccess:function(data){
	           	 if(data.status != 0){
	           		 $.messager.alert('系统消息',data.errMsg,'error');
	           	 }
	           	 if(data.rows.length > 0 ){
		           	 $(this).datagrid('selectRow',0);
	           	 }
	           	
				var v = $("#isGoodCard").combobox("getValue");
				$("#form").form("reset");
				$("#isGoodCard").combobox("setValue", v);
            },
            onSelect:function(index,data){
            	if(data == null)return;
	            $("#accinfo").get(0).src =  "/jsp/cardService/inneraccinfo.jsp?cardNo=" + data.CARD_NO;
	            if($("#accinfodiv").css("display") != "block"){
		            $("#accinfodiv").show();
	            }
            }
		 });
	});
	function query(){
		if($("#certNo").val().replace(/\s/g,'') == '' && $("#cardNo").val().replace(/\s/g,'') == ''){
			$.messager.alert('系统消息','请输入查询证件号码或是卡号！','error');
			return;
		}
		if($('#isGoodCard').combobox('getValue') == '0' && isreadcard != 0){
			$.messager.alert('系统消息','已选择是好卡，请先进行读卡，再进行查询！','error');
			return;
		}
		isquery = '0';
		if(curreadcardno != $("#cardNo").val()){
			$('#cardAmt').val('0');
			$("#isGoodCard").combobox('setValue','1')
		}
		if($("#isGoodCard").combobox('getValue') == '1'){
			$('#cardAmt').val('0');
		}
		//$("#isGoodCard").combobox("disable");
		if($("#accinfodiv").css("display") == "block"){
			accinfo.window.deleteAllData();
			$("#accinfodiv").hide();
		}
		$("input[type=checkbox]").each(function(){
			this.checked = false;
		});
		$cardinfo.datagrid('load',{
			queryType:'0',
			//certType:$("#certType").combobox('getValue'), 
			certNo:$('#certNo').val(),
			cardNo:$('#cardNo').val()
		});
	}
	function readCard(){
		$.messager.progress({text:'正在获取卡信息，请稍后....'});
		cardmsg = getcardinfo();
		if(dealNull(cardmsg["card_No"]).length == 0){
			$.messager.progress('close');
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
			return;
		}
		$.messager.progress('close');
		$("#cardNo").val(cardmsg["card_No"]);
		$("#cardAmt").val((parseFloat(isNaN(cardmsg['wallet_Amt']) ? 0:cardmsg['wallet_Amt'])/100).toFixed(2));
		isreadcard = 0;
		curreadcardno = cardmsg["card_No"];
		$("#isGoodCard").combobox('setValue','0');
		//$("#isGoodCard").val('0');
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
		//$("#certType").combobox("setValue",'1');
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
				$.messager.alert("系统消息","选择的卡类型当前不允许注销！","error");
				return;
			}
			if($('#isGoodCard').combobox("getValue") == '0' && isreadcard != 0){
				$.messager.alert("系统消息","已经选择是好卡，请先进行读卡，在进行查询！","warning");
				return;
			}
			if($('#zxreason').combobox("getValue") == '') {
				$.messager.alert("系统消息","请选择注销原因！","error",function(){
					$('#zxreason').combobox("showPanel");
				});
				return;
			}
			$.messager.confirm('系统消息','您确定要注销该卡片吗？',function(is){
				if(is){
					$.messager.progress({text : '数据处理中，请稍后....'});
					$.post('cardService/cardServiceAction!zx.action',$('form').serialize()+ "&cardNo=" + curcard.CARD_NO + "&cardAmt=" + $('#cardAmt').val(),function(data,status){
						$.messager.progress('close');
						if(status == 'success'){
							$.messager.alert('系统消息',data.msg,(data.status == 0 ? 'info' : 'error'),function(){
								if(data.status == '0'){
									showReport("卡片注销",data.dealNo);
									$cardinfo.datagrid("reload");
									$("#form").form("reset");
								}
							});
						}else{
							$.messager.alert('系统消息','请求出现错误，请稍后重试！','error');
						}
					},'json');
				}
			});
		}else{
			$.messager.alert("系统消息","请选择一条卡信息记录进行注销！",'warning');
		}
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
		<div class="well well-small datagrid-toolbar">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>卡片进行注销操作！</strong><span style="color:red;font-weight:600;">注意：</span>坏卡注销后，需待指定工作日后才能进行账户余额返还操作；好卡注销可立即进行账户余额返还！</span></span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="height:50px;margin:0px;width:auto;border-bottom:none;border-left:none;">
	  	<div id="tb" style="padding:2px 0">
			<table class="tablegrid">
				<tr>
					<tr>
						<td style="padding-left:2px">证件号码：</td>
						<td style="padding-left:2px"><input name="certNo"  class="textinput" id="certNo" type="text" /></td>
						<td style="padding-left:2px">卡号：</td>
						<td style="padding-left:2px"><input name="cardNo"  class="textinput" id="cardNo" type="text" /></td>
						<td style="padding-left:2px">卡余额：</td>
						<td style="padding-left:2px"><input id="cardAmt" type="text" class="textinput" name="cardAmt" style="width:174px;" readonly="readonly"/></td>
						<td style="padding-left:2px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="readCard()">读卡</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="readIdCard()">读身份证</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-ok'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="zx()">确定</a>
						</td>
				</tr>
			</table>
		</div>
  		<table id="cardinfo" title="卡信息" style="height:150px;"></table>
	</div>
	<div data-options="region:'south',split:false,border:true" style="height:300px;width:auto;text-align:center;overflow:hidden;border-bottom:none;border-left:none;">
		<div style="width:100%;display:none;" id="accinfodiv" class="datagrid-toolbar">
  			<h3 class="subtitle">账户信息</h3>
  			<iframe name="accinfo" id="accinfo"  width="100%" frameborder="0" style="border:none;height:78px;padding:0px;margin:0px;"></iframe>
		</div>
		<div style="width:100%;height:100%">
			<form id="form" method="post" style="width:100%;height:100%" class="datagrid-toolbar">
				 <h3 class="subtitle">代理人信息</h3>
				 <table class="tablegrid" style="width:100%;">
					 <tr>
					    <th class="tableleft">原卡状态：</th>
						<td class="tableright"><input name="isGoodCard" id="isGoodCard" value="1" class="textinput easyui-validatebox" type="text" required="required"/></td>
						<th class="tableleft">注销原因：</th>
						<td class="tableright"><input name="zxreason" id="zxreason"  value="2" class="textinput easyui-validatebox" type="text" required="required"/></td>
						<th class="tableleft">代理人证件类型：</th>
						<td class="tableright"><input id="agtCertType" type="text" class="easyui-combobox  easyui-validatebox" name="rec.agtCertType" value="1" style="width:174px;"/> </td>
					</tr>
					<tr>
						<th class="tableleft">代理人证件号码：</th>
						<td class="tableright"><input name="rec.agtCertNo"  class="textinput easyui-validatebox" id="agtCertNo" type="text" validtype="idcard" maxlength="18"/></td>
						<th class="tableleft">代理人姓名：</th>
						<td class="tableright"><input name="rec.agtName" id="agtName" type="text" class="textinput easyui-validatebox"  maxlength="30"  /></td>
					 	<th class="tableleft">代理人联系电话：</th>
						<td class="tableright">
							<input name="rec.agtTelNo" id="agtTelNo" type="text" class="textinput easyui-validatebox" maxlength="11"  validtype="mobile"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readSMK2()">读市民卡</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard2()">读身份证</a>
						</td>
					</tr>
			  </table>
		  </form>	
	 </div>		
</div>
</body>
</html>