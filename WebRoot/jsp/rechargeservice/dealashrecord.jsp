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
    <title>灰记录处理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $dg;
	var $temp;
	var $grid;
	var cardinfo;
	$(function(){
		$(document).keypress(function(event){
			if(event.keyCode == 13){
				query();
			}
		});
		
		createSysCode({id:"cardType",codeType:"CARD_TYPE"});
		createSysBranch(
			{id:"branchId"},
			{id:"operId"}
		);
		$dg = $("#dg");
		$.autoComplete({
			id:"certNo",
			text:"cert_no",
			value:"name",
			table:"base_personal",
			keyColumn:"cert_no"
			//minLength:"1"
		});
		$grid = $dg.datagrid({
			url : "recharge/rechargeAction!dealAshRecord.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			fitColumns:true,
			scrollbarSize:0,
			frozenColumns : [[
					{field:'V_V',sortable:true,checkbox:true},
					{field:'DEAL_NO',title:'流水号',sortable:true,width:parseInt($(this).width() * 0.07)},
					{field:'DEAL_CODE_NAME',title:'业务类型',sortable:true,width:parseInt($(this).width() * 0.12)},
					{field:'CR_CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width() * 0.08)},
					{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width() * 0.14)}
			]],
			columns : [[
					{field:'CR_CARD_NO',title:'卡号',sortable:true},
					{field:'CARDTYPE',title:'卡类型',sortable:true},
					{field:'CARD_BAL',title:'交易前卡余额',align:'right',sortable:true},
					{field:'CR_AMT',title:'交易金额',align:'right',sortable:true},
					{field:'CR_CARD_COUNTER',title:'卡计数器',sortable:true},
					{field:'DEAL_DATE',title:'业务时间',sortable:true},
					{field:'CLR_DATE',title:'清分日期',sortable:true},
					{field:'FULL_NAME',title:'受理点',sortable:true},
					{field:'OPERNAME',title:'受理柜员',sortable:true}
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
		$dg.datagrid('load',{
			queryType:'0',
			certNo:$('#certNo').val(), 
			cardType:$("#cardType").combobox('getValue'),
			cardNo:$('#cardNo').val(),
			branchId: $("#branchId").combobox('getValue'),
			operId:$("#operId").combobox('getValue'),
			beginTime:$('#beginTime').val(),
			endTime:$('#endTime').val()
		});
	}
	function saveCancel(){
		var temprow = $dg.datagrid('getSelected');
		if(temprow){
			$.messager.confirm('系统消息','您确定要撤销卡号为【' + temprow.CR_CARD_NO + '】，流水号为:' + temprow.DEAL_NO + '的【' + temprow.DEAL_CODE_NAME + '】灰记录信息吗？',function(is){
				if(is){
					$.messager.progress({text:'正在进行撤销,请稍后...'});
					$.ajax({
							data:{dealNo:temprow.DEAL_NO},
						    dataType:"json",
						    error:function(){
						    	$.messager.progress('close');
						    	$.messager.alert("系统消息","灰记录取消发生错误，请重试！");
						    },
						    success:function(data){
						    	$.messager.progress('close');
						    	$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
						    		$dg.datagrid('reload');
						    	});
						    },
						    url:"recharge/rechargeAction!dealAshRecordCancel.action"
				    });
				}
			});
		}else{
			$.messager.alert("系统消息","灰记录取消，请选择一条充值记录！","error");
			return;
		}
	}
	//灰记录手工确认
	function saveconfirm(){
		var temprow = $dg.datagrid('getSelected');
		if(temprow){
			$.messager.confirm('系统消息','您确定要确认卡号为【' + temprow.CR_CARD_NO + '】，流水号为:' + temprow.DEAL_NO + '的【' + temprow.DEAL_CODE_NAME + '】灰记录信息吗？',function(is){
				if(is){
					$.messager.progress({text : '正在进行确认,请稍后...'});
					$.ajax({
							data:{dealNo:temprow.DEAL_NO},
						    dataType:"json",
						    error:function(){
						    	$.messager.progress('close');
						    	$.messager.alert("系统消息","灰记录确认发生错误，请重试！");
						    },
						    success:function(data){
						    	$.messager.progress('close');
						    	$.messager.alert("系统消息",data.msg,(data.status == "0" ? "info" : "error"),function(){
						    		$dg.datagrid('reload');
						    	});
						    },
						    url:"recharge/rechargeAction!dealAshRecordConfrim.action"
				    });
				}
			});
		}else{
			$.messager.alert("系统消息","灰记录处理请选择一条记录信息！","error");
			return;
		}
	}
	function readCard(){
		try{
			cardinfo = getcardinfo();
			if(dealNull(cardinfo['card_No']).length == 0){
				$.messager.alert('系统消息','读卡出现错误，请拿起并重新放置好卡片，再次进行读取！' + cardinfo["errMsg"],'error');
			}else{
				$('#cardNo').val(cardinfo['card_No']);
				$('#cardAmt').val(Number(cardinfo['wallet_Amt']).div100());
				query();
			}
		}catch(e){
			errorsMsg = "";
			for (i in e) {
				errorsMsg += i + ":" + eval("e." + i) + "\n";
			}
			$.messager.alert('系统消息',errorsMsg,'error');
		}
	}
	function readIdCard(){
		var o = getcertinfo();
		if(dealNull(o["name"]).length == 0){
			return;
		}
		$("#certNo").val(o["cert_No"]);
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>
				在此你可以对<span class="label-info"><strong>系统灰记录</strong></span>进行<span class="label-info">确认或冲正操作！<span style="color:red;font-weight:600">注意：</span>处理灰记录前请确认该业务是否成功或是失败，若成功将进行确认，若失败将进行冲正！</span>
			</span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="height:50px;margin:0px;width:auto;border-left:none;border-bottom:none;">
	  	<div id="tb" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
				<tr>
					<td class="tableleft">所属网点：</td>
					<td class="tableright"><input id="branchId" type="text" class="textinput" name="branchId"/></td>
					<td class="tableleft">柜员：</td>
					<td class="tableright"><input id="operId" type="text" class="textinput" name="operId"/></td>
					<td class="tableleft">起始日期：</td>
					<td class="tableright"><input  id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
				</tr>
				<tr>
					<td class="tableleft">结束日期：</td>
					<td class="tableright"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					<!-- <td class="tableleft">证件类型：</td>
					<td class="tableright"><input id="certType" type="text" class="easyui-combobox  easyui-validatebox" name="certType" value="" style="width:174px;cursor:pointer;"/></td>-->
					<td class="tableleft">证件号码：</td>
					<td class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text" /></td> 
					<td class="tableleft">卡类型：</td>
					<td class="tableright"><input id="cardType" type="text" class="easyui-combobox  easyui-validatebox" name="cardType" value="100" style="width:174px;"/></td>
				</tr>
				<tr>
					<td class="tableleft">卡号：</td>
					<td class="tableright"><input name="cardNo"  class="textinput" id="cardNo" type="text" /></td>
					<td class="tableleft">卡内余额：</td>
					<td class="tableright"><input name="cardAmt"  class="textinput" id="cardAmt" type="text" disabled="disabled"/></td>
					<td class="tableright" colspan="2" style="padding-left: 20px">
						<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton"  id="readcard" name="readcard"  onclick="readCard()">读卡</a>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="readIdCard()">读身份证</a>
						<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						<shiro:hasPermission name="ashrecordcofirmsave">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-ok'" href="javascript:void(0);" class="easyui-linkbutton" onclick="saveconfirm()">确认</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="ashrecordcanelsave">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-back'" href="javascript:void(0);" class="easyui-linkbutton" onclick="saveCancel()">撤销</a>
						</shiro:hasPermission>
				</tr>
			</table>
		</div>
  		<table id="dg" title="灰记录信息"></table>
	</div>
</body>
</html>
