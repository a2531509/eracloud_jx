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
    <title>商户结算审核</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		var totalAmt=0.00;
		var totalThAmt=0.00;
		var totalStlAmt=0.00;
		var totalNum=0;
		var totalFee=0.00;
		function setValue(vTxt) {
	       $('#merchantId').combobox('setValue', vTxt);
	    }
		$(function() {
			//结算状态
			$("#stlState").combobox({
				width:174,
				valueField:'codeValue',
				editable:false,
				value:"",
			    textField:"codeName",
			    panelHeight:'auto',
			    data:[{codeValue:'',codeName:"请选择"},{codeValue:'0',codeName:"待审核"},{codeValue:'1',codeName:"已审核"},{codeValue:'2',codeName:"已导出"},{codeValue:'9',codeName:"已支付"}]
			});

			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "/merchantSettle/merchantSettleAction!toSettlementReport.action",
				pagination:true,
				rownumbers:true,
				border:false,
				fit:true,
				singleSelect:false,
				checkOnSelect:true,
				striped:true,
				autoRowHeight:true,
				fitColumns: true,
				pageList:[100, 500, 1000, 2000, 5000],
				showFooter: true,
				scrollbarSize:0,
				columns : [ [ 
								{field:'SETTLEID',title:'id',sortable:true,checkbox:'ture'},
								{field:'MERCHANT_ID',title:'商户编号',sortable:true,width : parseInt($(this).width() * 0.09)},
								{field:'MERCHANT_NAME',title:'商户名称',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'STL_MODE',title:'结算模式',sortable:true,width : parseInt($(this).width() * 0.04)},
								{field:'TOT_DEAL_NUM',title:'总笔数',sortable:true,width : parseInt($(this).width() * 0.06)},
								{field:'TOT_DEAL_AMT',title:'总金额',sortable:true,width : parseInt($(this).width() * 0.06), formatter:formatAmt},
								{field:'DEAL_FEE',title:'服务费',sortable:true,width : parseInt($(this).width() * 0.05), formatter:formatAmt},
								{field:'TH_AMT',title:'退货金额',sortable:true,width : parseInt($(this).width() * 0.05), formatter:formatAmt},
								{field:'STL_AMT',title:'结算金额',sortable:true,width : parseInt($(this).width() * 0.08), formatter:formatAmt},
								{field:'STL_STATE',title:'结算状态',sortable:true,width : parseInt($(this).width() * 0.04)}
				              ]],
				              toolbar:'#tb',
				              onCheck:function(index,data){
				            	  totalAmt=parseFloat(totalAmt)+parseFloat(data.TOT_DEAL_AMT);
				            	  totalThAmt=parseFloat(totalThAmt)+parseFloat(data.TH_AMT);
				            	  totalStlAmt=parseFloat(totalStlAmt)+parseFloat(data.STL_AMT);
				            	  totalFee=parseFloat(totalFee)+parseFloat(data.DEAL_FEE);
				            	  totalNum=parseFloat(totalNum)+parseFloat(data.TOT_DEAL_NUM);
				            	  $('#dg').datagrid('reloadFooter',[
				            	                                	{MERCHANT_NAME:'本页信息统计：',DEAL_FEE:parseFloat(totalFee).toFixed(2),TOT_DEAL_NUM : totalNum,TOT_DEAL_AMT: parseFloat(totalAmt).toFixed(2),TH_AMT: parseFloat(totalThAmt).toFixed(2),STL_AMT: parseFloat(totalStlAmt).toFixed(2)}
				            	                                ]);
				              },
				              onUncheck:function(index,data){
				            	  totalAmt=parseFloat(totalAmt)-parseFloat(data.TOT_DEAL_AMT);
				            	  totalThAmt=parseFloat(totalThAmt)-parseFloat(data.TH_AMT);
				            	  totalStlAmt=parseFloat(totalStlAmt)-parseFloat(data.STL_AMT);
				            	  totalNum=parseFloat(totalNum)-parseFloat(data.TOT_DEAL_NUM);
				            	  totalFee=parseFloat(totalFee)-parseFloat(data.DEAL_FEE);
				            	  $('#dg').datagrid('reloadFooter',[
				            	                                	{MERCHANT_NAME:'本页信息统计：',DEAL_FEE:parseFloat(totalFee).toFixed(2),TOT_DEAL_NUM : totalNum,TOT_DEAL_AMT: parseFloat(totalAmt).toFixed(2),TH_AMT: parseFloat(totalThAmt).toFixed(2),STL_AMT: parseFloat(totalStlAmt).toFixed(2)}
				            	                                ]);
				              },
				              onCheckAll:function(rows){
				            	  for(var i=0;i<rows.length;i++){
				            		  totalAmt=parseFloat(totalAmt)+parseFloat(rows[i].TOT_DEAL_AMT);
				            		  totalThAmt=parseFloat(totalThAmt)+parseFloat(rows[i].TH_AMT);
					            	  totalStlAmt=parseFloat(totalStlAmt)+parseFloat(rows[i].STL_AMT);
					            	  totalNum=parseFloat(totalNum)+parseFloat(rows[i].TOT_DEAL_NUM);
					            	  totalFee=parseFloat(totalFee)+parseFloat(rows[i].DEAL_FEE);
					            	  $('#dg').datagrid('reloadFooter',[
					            	                                	{MERCHANT_NAME:'本页信息统计：',DEAL_FEE:parseFloat(totalFee).toFixed(2),TOT_DEAL_NUM : totalNum,TOT_DEAL_AMT: parseFloat(totalAmt).toFixed(2),TH_AMT: parseFloat(totalThAmt).toFixed(2),STL_AMT: parseFloat(totalStlAmt).toFixed(2)}
					            	                                ]);
				            	  }
				              },
				              onUncheckAll:function(rows){
				            	  for(var i=0;i<rows.length;i++){
				            		  totalAmt=parseFloat(totalAmt)-parseFloat(rows[i].DEAL_AMT);
				            		  totalThAmt=parseFloat(totalThAmt)-parseFloat(rows[i].TH_AMT);
					            	  totalStlAmt=parseFloat(totalStlAmt)-parseFloat(rows[i].STL_AMT);
					            	  totalNum=parseFloat(totalNum)-parseFloat(rows[i].DEAL_NUM);
					            	  totalFee=parseFloat(totalFee)-parseFloat(rows[i].DEAL_FEE);
					            	  $('#dg').datagrid('reloadFooter',[
					            	                                	{MERCHANT_NAME:'本页信息统计：',DEAL_FEE:parseFloat(totalFee).toFixed(2),DEAL_NUM : totalNum,DEAL_AMT: parseFloat(totalAmt).toFixed(2),TH_AMT: parseFloat(totalThAmt).toFixed(2),STL_AMT: parseFloat(totalStlAmt).toFixed(2)}
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
		
		function formatAmt(s, n) {
			if(isNaN(n) || n < 0 || n >= 20){
				n = 2;
			}
			
			s = parseFloat((s + "").replace(/[^\d\.-]/g, ""));
			
			if(isNaN(s)){
				s = 0;
			}
			
			s = s.toFixed(n);

			var l = (s + "").split(".")[0].split("").reverse();
			
			var r = s.split(".")[1];
			
			var t = "";
			
			for(i = 0; i < l.length; i ++ ) {  
				t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length && l[i + 1] != "-" ? "," : "");
			}
			
			return t.split("").reverse().join("") + "." + r; 
		}
		
		function query(){
			totalAmt=0.00;
			totalThAmt=0.00;
			totalStlAmt=0.00;
			totalFee=0.00;
			totalNum=0;
			if($("#year").val()==''){
				parent.$.messager.show({
					title :'系统消息',
					msg : '请输入查询年份！',
					timeout : 1000 * 3
    			});
				return false;
			}
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				merchantId:$("#merchantId").val(),
				year:$("#year").val(),
				stlState:$("#stlState").combobox('getValue')
			});
		}
		
		function print(){
			if($("#year").val()==''){
				parent.$.messager.show({
					title :'系统消息',
					msg : '请输入查询月份！',
					timeout : 1000 * 3
    			});
				return false;
			}
			var rows = $dg.datagrid('getChecked');
			var stlSumNo="";
			if (rows.length>0) {
				for(var i=0;i<rows.length;i++){
					if(i==rows.length-1){
						stlSumNo=stlSumNo+rows[i].SETTLEID;
					}else{
						stlSumNo=stlSumNo+rows[i].SETTLEID+"|";
					}
				}
				$.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
				$.post("/merchantSettle/merchantSettleAction!printReport.action",
						{
							stlSumNo:stlSumNo,
							year:$("#year").val()
						},
						function(rsp,status){
							$.messager.progress('close');
						if(rsp.status){
							showReport('<%=com.erp.util.Constants.APP_REPORT_TITLE%>',rsp.actionNo);
						}else{
							parent.$.messager.show({
								title :"提示",
								msg :rsp.message,
								timeout : 1000 * 2
							});
						}
					},'json');
			}else{
				parent.$.messager.show({
					title :"提示",
					msg :"请选择记录!",
					timeout : 1000 * 2
				});
			}
			
		}

		
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
	</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left: 0px;margin-top: 2px;margin-right: 0px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>商户结算</strong></span>进行年报查询!</span>
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
						<td class="tableleft">结算状态：</td >
						<td class="tableright">
							<input id="stlState" class="easyui-combobox easyui-validatebox" name="stlState" style="width:174px;" />
						</td>
						<td class="tableleft">年份：</td>
						<td class="tableright">
							<input id="year" type="text" name="year" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy'})"/>
						<td style="padding-left:2px" colspan="2">
								<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<shiro:hasPermission name="viewMerSettleInfo">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-print"  plain="false" onclick="print();">打印</a>
							</shiro:hasPermission>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="结算信息"></table>
	  </div>
  </body>
</html>
