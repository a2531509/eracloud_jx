<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>申领历史信息查询</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">   
	<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript" src="js/jquery-ui.js"></script>
<script type="text/javascript">
	var  $personinfo;//人员列表
	$(function(){
		addNumberValidById("applyId");
		selectByType('applyWay','APPLY_WAY');
		$("#branchId").combobox({ 
		    url:"commAction!getAllBranchs.action",
		    editable:false,
		    cache: false,
		    panelHeight: 'auto',
		    valueField:'branch_Id',   
		    textField:'branch_Name',
		    formatter:function(row){
	    		var temptext = "<span>";
		    	if(row.leval){
		    		for(var i = 0; i < (row.leval-1) * 8;i++){
		    			temptext += "&nbsp;";
		    		}
		    	}
	    		return temptext + row.branch_Name +"</span>";
		    },
		    onLoadSuccess:function(){
		    	//1.加载成功后,设置默认
		    	var options = $("#branchId").combobox('getData');
		    	var len = options.length;
		    	if(len > 0){
		    		$(this).combobox('setValue',options[0].branch_Id);
			    	$("#operId").combobox('reload','commAction!getAllOperators.action?branch_Id=' + options[0].branch_Id);
		    	}
		    },
		    onSelect:function(option){
		    	$("#operId").combobox('clear');
		    	$("#operId").combobox('reload','commAction!getAllOperators.action?branch_Id=' + option.branch_Id);
		    }
 		});
 		$("#regionId").combobox({ 
		    url:"commAction!getAllRegion.action",
		    editable:false,
		    cache: false,
		    panelHeight:'auto',
		    valueField:'region_Id',   
		    textField:'region_Name',
	    	onSelect:function(node){
	    		$("#townId").combobox('clear');
	    		$("#townId").combobox('reload','commAction!getAllTown.action?region_Id=' + node.region_Id);
	    	},
	    	onLoadSuccess:function(){
		 		var cys = $("#regionId").combobox('getData');
		 		if(cys.length > 0){
		 			$(this).combobox('setValue',cys[0].region_Id);
		 			$("#townId").combobox('clear');
		 			$("#townId").combobox('reload','commAction!getAllTown.action?region_Id=' + cys[0].region_Id);
		 		}
		    }
 		 }); 
		 $("#townId").combobox({ 
		    editable:false,
		    cache: false,
		    panelHeight:'auto',
		    valueField:'town_Id',   
		    textField:'town_Name',
		    onSelect:function(node){
	    		$("#commId").combobox('clear');
	    		$("#commId").combobox('reload','commAction!getAllComm.action?town_Id=' + node.town_Id);
	    	},
	    	onLoadSuccess:function(){
		 		var cys = $("#townId").combobox('getData');
		 		if(cys.length > 0){
		 			$(this).combobox('setValue',cys[0].town_Id);
		 			$("#commId").combobox('clear');
		 			$("#commId").combobox('reload','commAction!getAllComm.action?town_Id=' + cys[0].town_Id);
		 		}
		    }
 		 });
		 $("#commId").combobox({ 
		    editable:false,
		    cache: false,
		   // multiple:true,
		    //panelHeight:'auto',
		    valueField:'comm_Id',   
		    textField:'comm_Name'
 		 });
		$("#operId").combobox({ 
		    url:"commAction!getAllOperators.action",
		    editable:false, //不可编辑状态
		    cache: false,
		    panelHeight: 'auto',//自动高度适合
		    valueField:'user_Id',   
		    textField:'user_Name',
		    onLoadSuccess:function(){
		    	var options = $(this).combobox('getData');
		    	var len = options.length;
		    	if(len > 0){
		    		$(this).combobox('setValue',options[0].user_Id);
		    	}
		    }
 		 }); 
		 $personinfo = $("#personinfo");
		 $personinfo.datagrid({
			url : "/cardapply/cardApplyAction!toSearchApplyMsg.action",
			fit:true,
			//scrollbarSize:0,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			//fitColumns:true,
			pageList:[10,20,30,40,50],
			pageSize:20,
			frozenColumns:[[
					{field:'APPLY_ID',title:'申领编号',sortable:true,width:parseInt($(this).width() * 0.05)},
					{field:'MAKE_BATCH_ID',title:'批次号',sortable:true,width:parseInt($(this).width() * 0.04)},
					{field:'CUSTOMER_ID',title:'客户编号',sortable:true,width:parseInt($(this).width() * 0.07)},
					{field:'NAME',title:'姓名',sortable:true,width:parseInt($(this).width() * 0.05)},
					{field:'CERTTYPE',title:'证件类型',sortable:true,width:parseInt($(this).width() * 0.05)},
					{field:'CERT_NO',title:'证件号码',sortable:true,width:parseInt($(this).width() * 0.12)},
					{field:'GENDER',title:'性别',sortable:true,width:parseInt($(this).width() * 0.03)},
			]],
			columns:
				[[
					{field:'APPLY_WAY',title:'申领方式',sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:'APPLY_TYPE',title:'申领类型',sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:'APPLYDATE',title:'申领时间',sortable:true,width:parseInt($(this).width() * 0.11)},
					{field:'CARDTYPE',title:'卡类型',sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:'CARD_NO',title:'卡号',sortable:true,width:parseInt($(this).width() * 0.13)},
					{field:'APPLYSTATE',title:'申领状态',sortable:true,width:parseInt($(this).width() * 0.08)},
					{field:'FULL_NAME',title:'办理网点',sortable:true,width:parseInt($(this).width() * 0.08)},
					{field:'USERNAME',title:'办理柜员',sortable:true,width:parseInt($(this).width() * 0.08)},
					{field:'REGION_NAME',title:'所属区域',sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:'TOWN_NAME',title:'乡镇（街道）',sortable:true,width:parseInt($(this).width() * 0.11),formatter:function(value,row,index){
						return '<div style="width:100%;height:100%;" title="' + value + '">' + value + "</span>";
					}},
					{field:'COMM_NAME',title:'社区（村）',sortable:true,width:parseInt($(this).width() * 0.11),formatter:function(value,row,index){
						return '<div style="width:100%;height:100%;" title="' + value + '">' + value + "</span>";
					}},
					{field:'CORP_NAME',title:'单位',sortable:true,width:parseInt($(this).width() * 0.11),formatter:function(value,row,index){
						return '<div style="width:100%;height:100%;" title="' + value + '">' + value + "</span>";
					}}
				]],
		 	toolbar:'#tb',
		 	onLoadSuccess:function(data){
		 		if(dealNull(data.errMsg).length > 0){
		 			$.messager.alert('系统消息',data.errMsg,'error');
		 		}
		 		var allch = $(':checkbox').get(0);
		 		if(allch){
		 			allch.checked = false;
		 		}
		 		//$personinfo.datagrid('resize',{scrollbarSize:18});
		 	}
		 });
	});
	//查询
	function query(){
		var params = {};
		params['queryType'] = '0';
		params['taskId'] = $("#taskId").val();
		params['apply.applyWay'] = $("#applyWay").combobox("getValue");
		params['apply.buyPlanId'] = $("#makeBatchId").val();
		params['apply.applyId'] = $("#applyId").val();
		
		params['bp.name'] = $("#name").val();
		params['bp.certNo'] = $("#certNo").val();
		
		params['apply.applyBrchId'] = $("#branchId").combobox('getValue');
		params['apply.applyUserId'] =  $("#operId").combobox('getValue');
		
		params['bp.corpCustomerId'] = $("#corpCustomerId").val();
		params['corpName'] = $("#companyName").val();
		params['beginTime'] = $("#beginTime").val();
		params['endTime'] = $("#endTime").val();
		
		params['bp.regionId'] = $('#regionId').combobox('getValue');
		params['bp.townId'] = $('#townId').combobox('getValue');
		params['bp.commId'] = $('#commId').combobox('getValue');
		$personinfo.datagrid('load',params);
	}
	function autoCom(){
		if($("#corpCustomerId").val() == ""){
			$("#companyName").val("");
			return;
		}
		$("#corpCustomerId").autocomplete({
			position: {my:"left top",at:"left bottom",of:"#corpCustomerId"},
		    source: function(request,response){
			    $.post('dataAcount/dataAcountAction!toSearchInput.action',{"corpName":$("#corpCustomerId").val()},function(data){
			    	response($.map(data,function(item){return {label:item.text,value:item.value}}));
			    });
		    },
		    select: function(event,ui){
		      	$('#corpCustomerId').val(ui.item.label);
		        $('#companyName').val(ui.item.value);
		        return false;
		    }
	    });
	}
	function autoComByName(){
		if($("#companyName").val() == ""){
			$('#corpCustomerId').val("");
			return;
		}
		$("#companyName").autocomplete({
	    source:function(request,response){
	        $.post('dataAcount/dataAcountAction!toSearchInput.action',{"corpName":$("#companyName").val(),"queryType":"0"},function(data){
	            response($.map(data,function(item){return {label:item.value,value:item.text}}));
	        });
	    },
	    select: function(event,ui){
	      	$('#corpCustomerId').val(ui.item.value);
	        $('#companyName').val(ui.item.label);
	        return false;
	    },
	    focus: function(event,ui){
	    	//$('#corpCustomerId').val(ui.item.value);
		    //$('#corpName').val(ui.item.label);
	        return false;
	    }
	    }); 
	}
	function readIdCard(){
		var certinfo = getcertinfo();
		if(dealNull(certinfo["name"]) == ""){
			return;
		}else{
			$("#certNo").val(certinfo["cert_No"]);
		}
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top:2px;margin-bottom:2px;">
			<span class="badge">提示</span><span>在此您可以进行<span class="label-info"><strong>申领信息预览</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="margin:0px;width:auto">
	  	<div id="tb" style="padding:2px 0">
	  		<form id="applyMsgForm">
				<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
					<tr id="dwapply">
						<td  class="tableleft" style="width:8%">任务编号：</td>
						<td  class="tableright"><input name="taskId"  class="textinput" id="taskId" type="text"/></td>
						<td  class="tableleft" style="width:8%">批次号：</td>
						<td  class="tableright"><input name="makeBatchId"  class="textinput" id="makeBatchId" type="text"/></td>
						<td  class="tableleft">申领编号：</td>
						<td  class="tableright"><input name="apply.applyId"  class="textinput" id="applyId" type="text"/></td>
						<td  class="tableleft">申领方式：</td>
						<td  class="tableright"><input name="apply.applyWay"  class="textinput" id="applyWay" type="text"/></td>
					</tr>
					<tr>
						<td  class="tableleft">客户姓名：</td>
						<td  class="tableright"><input name="bp.name"  class="textinput" id="name" type="text"/></td>
						<td  class="tableleft">证件号码：</td>
						<td  class="tableright"><input name="bp.certNo"  class="textinput" id="certNo" type="text"/></td>
						<td class="tableleft">办理网点：</td>
						<td class="tableright" colspan="1"><input name="apply.applyBrchId"  class="textinput" id="branchId" type="text"/></td>
						<td class="tableleft">办理柜员：</td>
						<td class="tableright" colspan="1"><input name="apply.applyUserId"  class="textinput" id="operId" type="text"/></td>
					</tr>
					<tr>
						<td class="tableleft">单位编号：</td>
						<td  class="tableright"><input name="apply.corpCustomerId"  class="textinput" id="corpCustomerId" type="text" onkeydown="autoCom()" onkeyup="autoCom()"/></td>
						<td  class="tableleft">单位名称：</td>
						<td  class="tableright" ><input name="companyName"  class="textinput" id="companyName" type="text" onkeydown="autoComByName()" onkeyup="autoComByName()"/></td>
						<td class="tableleft">申领起始时间：</td>
						<td class="tableright"><input name="beginTime"  class="Wdate textinput" id="beginTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">申领截至时间：</td>
						<td class="tableright" colspan="1"><input name="endTime"  class="Wdate textinput" id="endTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
					 	<td  class="tableleft">所属区域：</td>
						<td  class="tableright"><input name="bp.regionId"  class="easyui-combobox"  id="regionId"  type="text" style="width:174px;"/></td>
						<td  class="tableleft">乡镇（街道）：</td>
						<td  class="tableright"><input name="bp.townId"  class="easyui-combobox" id="townId"  type="text" style="width:174px;"/></td>
						<td  class="tableleft">社区（村）：</td>
						<td  class="tableright"><input name="bp.commId"  class="easyui-combobox easyui-validatebox" id="commId" type="text" style="width:174px;" /></td>
					    <td  align="center" colspan="2">
					    	<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readIdcard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readIdCard()">读身份证</a>
					    	<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0)" class="easyui-linkbutton" onclick="query()">查询</a>
					    </td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="personinfo" title="查询条件"></table>
	</div>
</body>
</html>