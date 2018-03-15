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
    <title>黑名单查询</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript"> 
		var $dg;
		var $temp;
		var $grid;
		var $querycerttype;
		$(function() {
			$("#blkState").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"有效"},{codeValue:'1',codeName:"无效"}]
			});
			createSysCode({
				id:"blkType",
				codeType:"BLK_TYPE"
			});
			createSysCode({
				id:"cardType",
				codeType:"CARD_TYPE"
			});
			createSysCode({
				id:"certType",
				codeType:"CERT_TYPE"
			});
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "statistical/statisticalAnalysisAction!cardBlackQuery.action",
				fit:true,
				pagination:true,
				rownumbers:true,
				border:false,
				striped:true,
				pageSize:20,
				singleSelect:true,
				autoRowHeight:true,
				fitColumns:true,
				scrollbarSize:0,
				showFooter: true,
				frozenColumns:[[
						{field:'DEAL_NO',title:'流水号',sortable:true,width:parseInt($(this).width()*0.06)},
						{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width()*0.06)},
						{field:'NAME',title:'客户姓名',sortable:true,width:parseInt($(this).width()*0.06)},
						{field:'CERTTYPE',title:'证件类型',sortable:true,width:parseInt($(this).width()*0.05)},
						{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width()*0.12)}
				]],
				columns :[[
						{field:'CARDTYPE',title:'卡类型',sortable:true,width:parseInt($(this).width()*0.05)},
						{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width()*0.13)},
						{field:'BLKTYPE',title:'黑名单类型',sortable:true},
						{field:'BLKSTATE',title:'黑名单状态',sortable:true},
						{field:'LASTDATA',title:'最后更新时间',sortable:true,width:parseInt($(this).width()*0.12)},
						{field:'DEAL_CODE_NAME',title:'关联业务',sortable:true},
						{field:'FULL_NAME',title:'生成网点',sortable:true},
						{field:'ONAME',title:'柜员',sortable:true},
						{field:'CLR_DATE',title:'清分日期',sortable:true},
					]],
				  toolbar:'#tb',
	              onLoadSuccess:function(data){
	            	  if(data.status != 0){
	            		 $.messager.alert('系统消息',data.errMsg,'error');
	            	  }
	              }
			});
		});
		function query(){
			var params = getformdata("businessFrom");
			params["queryType"] = "0";
			if(params["isNotBlankNum"] < 1){
				$.messager.alert("系统消息","查询参数不能全部为空！请至少输入或选择一个查询参数","warning");
				return;
			}
			if($("#beginTime").val().replace(/\s/g,"") != ""){
				params["beginTime"] = $("#beginTime").val().replace(/\D/g,"");
			}
			if($("#endTime").val().replace(/\s/g,"") != ""){
				params["endTime"] = $("#endTime").val().replace(/\D/g,"");
			}
			$dg.datagrid('load',params);
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
	</script>
  </head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>黑名单进行查询操作！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div id="tb" style="padding:2px 0">
		<form id="businessFrom">
			<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft">卡号：</td>
					<td class="tableright"><input  id="cardNo" type="text"  class="textinput" name="rec.cardNo"/></td>
					<td class="tableleft">卡类型：</td>
					<td class="tableright"><input  id="cardType" type="text"  class="textinput" name="rec.cardType"/></td>
					<td class="tableleft">黑名单类型：</td>
					<td class="tableright"><input  id="blkType" type="text"  class="textinput" name="cardBlaack.blkType"/></td>
				</tr>
				<tr>
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input  id="certNo" type="text"  class="textinput" name="rec.certNo"/></td>
					<td class="tableleft">证件类型：</td>
					<td class="tableright"><input  id="certType" type="text"  class="textinput" name="rec.certType"/></td>
					<td class="tableleft">记录状态：</td>
					<td class="tableright"><input  id="blkState" type="text" class="textinput" name="cardBlaack.blkState"/></td>
				</tr>
				<tr>
					<td class="tableleft">起始日期：</td>
					<td class="tableright"><input  id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false,maxDate:'%y-%M-%d 00:00:00'})"/></td>
					<td class="tableleft">结束日期：</td>
					<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					<td align="center" colspan="2">
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="readCard()">读卡</a>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="readIdCard()">读身份证</a>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
					</td>
				</tr>
			</table>
		</form>
		</div>
  		<table id="dg" title="黑名单信息"></table>
  </div>
</body>
</html>