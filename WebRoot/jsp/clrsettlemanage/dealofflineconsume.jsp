<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>脱机数据处理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
	<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript" src="js/jquery-ui.js"></script>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		var norNum=0;
		var norAmt=0.00;
		var refuseNum=0;
		var refuseAmt=0.00;
		var dealNum=0;
		var dealAmt=0.00;
		$(function(){
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url:"clrDeal/clrDealAction!findOfflineList.action",
				pagination:true,
				rownumbers:true,
				border:false,
				striped:true,
				fit:true,
				singleSelect:false,
				fitColumns:true,
				scrollbarSize:0,
				showFooter: true,
				pageSize:20,
				columns:[[
					{field:'ID',checkbox:true},
					{field:'MERCHANT_ID',title:'商户编号',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'MERCHANT_NAME',title:'商户名称',align:'center',sortable:true,width:parseInt($(this).width()*0.15)},
					{field:'CLR_DATE',title:'清算日期',align:'center',sortable:true,width:parseInt($(this).width()*0.08)},
					{field:'NORMOL_NUM',title:'正常清算笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'NORMOL_AMT',title:'正常清算金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'REFUSE_NUM',title:'拒付笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'REFUSE_AMT',title:'拒付金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'DEAL_NUM',title:'卡片发行方调整笔数',align:'center',sortable:true,width:parseInt($(this).width()*0.1)},
					{field:'DEAL_AMT',title:'卡片发行方调整金额',align:'center',sortable:true,width:parseInt($(this).width()*0.1)}
				]],toolbar:'#tb',
	              onCheck:function(index,data){
	            	  norNum=parseFloat(norNum)+parseFloat(data.NORMOL_NUM);
	            	  norAmt=parseFloat(norAmt)+parseFloat(data.NORMOL_AMT);
	            	  refuseNum=parseFloat(refuseNum)+parseFloat(data.REFUSE_NUM);
	            	  refuseAmt=parseFloat(refuseAmt)+parseFloat(data.REFUSE_AMT);
	            	  dealNum=parseFloat(dealNum)+parseFloat(data.DEAL_NUM);
	            	  dealAmt=parseFloat(dealAmt)+parseFloat(data.DEAL_AMT);
	            	  $('#dg').datagrid('reloadFooter',[
	            	                                	{MERCHANT_NAME:'本页信息统计：',NORMOL_AMT:parseFloat(norAmt).toFixed(2),NORMOL_NUM : norNum,REFUSE_AMT: parseFloat(refuseAmt).toFixed(2),REFUSE_NUM : refuseNum,DEAL_AMT: parseFloat(dealAmt).toFixed(2),DEAL_NUM: dealNum}
	            	                                ]);
	              },
	              onUncheck:function(index,data){
	            	  norNum=parseFloat(norNum)-parseFloat(data.NORMOL_NUM);
	            	  norAmt=parseFloat(norAmt)-parseFloat(data.NORMOL_AMT);
	            	  refuseNum=parseFloat(refuseNum)-parseFloat(data.REFUSE_NUM);
	            	  refuseAmt=parseFloat(refuseAmt)-parseFloat(data.REFUSE_AMT);
	            	  dealNum=parseFloat(dealNum)-parseFloat(data.DEAL_NUM);
	            	  dealAmt=parseFloat(dealAmt)-parseFloat(data.DEAL_AMT);
	            	  $('#dg').datagrid('reloadFooter',[
													    {MERCHANT_NAME:'本页信息统计：',NORMOL_AMT:parseFloat(norAmt).toFixed(2),NORMOL_NUM : norNum,REFUSE_AMT: parseFloat(refuseAmt).toFixed(2),REFUSE_NUM : refuseNum,DEAL_AMT: parseFloat(dealAmt).toFixed(2),DEAL_NUM: dealNum}
	            	                                ]);
	              },
	              onCheckAll:function(rows){
	            	  for(var i=0;i<rows.length;i++){
	            		  norNum=parseFloat(norNum)+parseFloat(rows[i].NORMOL_NUM);
	            		  norAmt=parseFloat(norAmt)+parseFloat(rows[i].NORMOL_AMT);
	            		  refuseNum=parseFloat(refuseNum)+parseFloat(rows[i].REFUSE_NUM);
	            		  refuseAmt=parseFloat(refuseAmt)+parseFloat(rows[i].REFUSE_AMT);
	            		  dealNum=parseFloat(dealNum)+parseFloat(rows[i].DEAL_NUM);
	            		  dealAmt=parseFloat(dealAmt)+parseFloat(rows[i].DEAL_AMT);
		            	  $('#dg').datagrid('reloadFooter',[
														  {MERCHANT_NAME:'本页信息统计：',NORMOL_AMT:parseFloat(norAmt).toFixed(2),NORMOL_NUM : norNum,REFUSE_AMT: parseFloat(refuseAmt).toFixed(2),REFUSE_NUM : refuseNum,DEAL_AMT: parseFloat(dealAmt).toFixed(2),DEAL_NUM: dealNum}
		            	                                ]);
	            	  }
	              },
	              onUncheckAll:function(rows){
	            	  for(var i=0;i<rows.length;i++){
	            		  norNum=parseFloat(norNum)-parseFloat(rows[i].NORMOL_NUM);
	            		  norAmt=parseFloat(norAmt)-parseFloat(rows[i].NORMOL_AMT);
	            		  refuseNum=parseFloat(refuseNum)-parseFloat(rows[i].REFUSE_NUM);
	            		  refuseAmt=parseFloat(refuseAmt)-parseFloat(rows[i].REFUSE_AMT);
	            		  dealNum=parseFloat(dealNum)-parseFloat(rows[i].DEAL_NUM);
	            		  dealAmt=parseFloat(dealAmt)-parseFloat(rows[i].DEAL_AMT);
		            	  $('#dg').datagrid('reloadFooter',[
														    {MERCHANT_NAME:'本页信息统计：',NORMOL_AMT:parseFloat(norAmt).toFixed(2),NORMOL_NUM : norNum,REFUSE_AMT: parseFloat(refuseAmt).toFixed(2),REFUSE_NUM : refuseNum,DEAL_AMT: parseFloat(dealAmt).toFixed(2),DEAL_NUM: dealNum}
		            	                                ]);
	            	  }
	              },
	              onLoadSuccess:function(data){
	            	  $("input[type='checkbox']").each(function(){ if(this.checked){ this.checked=false; } });//初始话默认不选中
	            	  if(data.status != 0){
	            		 $.messager.alert('系统消息',data.errMsg,'error');
	            	  }
	              }
			});
		});
		
		function autoCom(){
			if($("#merchantId").val() == ""){
				$("#merchantName").val("");
			}
			$("#merchantId").autocomplete({
				position: {my:"left top",at:"left bottom",of:"#merchantId"},
			    source: function(request,response){
				    $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantId":$("#merchantId").val(),"queryType":"1"},function(data){
				    	response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
				    },'json');
			    },
			    select: function(event,ui){
			      	$('#merchantId').val(ui.item.label);
			        $('#merchantName').val(ui.item.value);
			        return false;
			    },
		      	focus:function(event,ui){
			        return false;
		      	}
		    }); 
		}
		function autoComByName(){
			if($("#merchantName").val() == ""){
				$("#merchantId").val("");
			}
			$("#merchantName").autocomplete({
			    source:function(request,response){
			        $.post('merchantRegister/merchantRegisterAction!initAutoComplete.action',{"merchant.merchantName":$("#merchantName").val(),"queryType":"0"},function(data){
			            response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
			        },'json');
			    },
			    select: function(event,ui){
			    	$('#merchantId').val(ui.item.value);
			        $('#merchantName').val(ui.item.label);
			        return false;
			    },
			    focus: function(event,ui){
			        return false;
			    }
		    }); 
		}
		$(document).keydown(function (event){ 
			if(event.keyCode == 112){
				basePersonalinfoquery();
				event.preventDefault(); 
			}else if(event.keyCode == 115){
				addOrEditBasePersonal("1");
				event.preventDefault(); 
			}else{
				return true;
			}
		});
		
		//查询脱机消费对账数据
		function queryOfflineInfo(){
			if($("#merchantId").val() == ""){
				$.messager.alert("系统消息","请输入查询条件！<div style=\"color:red\">提示：商户编号编号</div>","warning");
				return;
			}
			$dg.datagrid("load",{
				queryType:"0",
				"merchantId":$("#merchantId").val(),
				"merchantName":$("#merchantName").val(),
				"startClrDate":$("#startClrDate").val(),
				"endClrDate":$("#endClrDate").val()
			});
		}
		//预览脱机消费对账明细
		function viewOfflinelist(){
			var rows = $dg.datagrid('getChecked');
			if(rows.length == 1){
				$.modalDialog({
					title:'清算明细数据',
					iconCls:'icon-termManage',
					fit:true,
					maximized:true,
					shadow:false,
					closable:false,
					maximizable:false,
					href:"jsp/clrsettlemanage/dealofflineconlist.jsp",
					onLoad:function(){
						if(rows.length == 1){
							viewOffineListByID(rows[0].ID);
						}
					},
					tools:[{
							iconCls:'icon_cancel_01',
							handler:function(){
								$.modalDialog.handler.dialog('destroy');
								$.modalDialog.handler = undefined;
							}
						}
					]
				});
			}else{
				$.messager.alert("系统消息","请选择一条记录信息进行预览！","error");
			}
		} 
		
	</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>公交消费数据进行查询！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;">
		<div id="tb" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft">商户编号：</td>
					<td class="tableright"><input type="text" name="merchantId" id="merchantId" class="textinput" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
					<td class="tableleft">商户名称：</td>
					<td class="tableright"><input type="text" name="merchantName" id="merchantName" class="textinput" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
					<td class="tableleft">清分开始日期：</td>
					<td class="tableright"><input type="text" name="startClrDate" id="startClrDate" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					<td class="tableleft">清分结束日期：</td>
					<td class="tableright"><input type="text" name="endClrDate" id="endClrDate" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
				</tr>
				<tr>
					<td class="tableright" colspan="8">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="queryOfflineInfo();">查询</a>
						<shiro:hasPermission name="viewGjMx">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo" plain="false" onclick="viewOfflinelist();">预览明细</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="电子钱包消费数据列表"></table>
  	</div>
</body>
</html>
